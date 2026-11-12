#!/usr/bin/env node
// Creates a SQL Server migration from the change in sqlserver/schema.prisma since the last one.
//
// Prisma's `migrate dev` needs a shadow database and would fight the filtered indexes below, so SQL
// Server migrations are made by diffing schema files instead: sqlserver/migrations/schema.snapshot.prisma
// holds the schema as of the last migration. The steps:
//   1. node sqlserver/generate-schema.mjs --check   (the generated schema must be current)
//   2. prisma migrate diff  snapshot (or empty) -> sqlserver/schema.prisma
//   3. post-process the SQL (see below)
//   4. write sqlserver/migrations/<timestamp>_<name>/migration.sql and update the snapshot
//
// Post-processing: Postgres lets any number of rows share NULL in a unique key; SQL Server allows one.
// Unique keys with nullable columns become filtered unique indexes (WHERE col IS NOT NULL ...),
// which is exactly the Postgres behaviour.
//
// Data changes in upstream Postgres migrations (UPDATE/INSERT statements, triggers, views) are not in
// the schema, so they are not carried over: add them by hand to the generated migration.sql.
//
// usage: node sqlserver/new-migration.mjs <name> [--print]
import cp from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const prismaDir = path.resolve(import.meta.dirname, "..");
const migrationsDir = path.join(import.meta.dirname, "migrations");
const schemaPath = path.join(import.meta.dirname, "schema.prisma");
const snapshotPath = path.join(migrationsDir, "schema.snapshot.prisma");

const name = (process.argv[2] || "").replace(/[^a-zA-Z0-9_]/g, "_");
const printOnly = process.argv.includes("--print");
if (!name && !printOnly) {
  console.error("usage: node sqlserver/new-migration.mjs <name> [--print]");
  process.exit(1);
}

cp.execFileSync(process.execPath, [path.join(import.meta.dirname, "generate-schema.mjs"), "--check"], {
  stdio: "inherit",
});
const { models } = JSON.parse(fs.readFileSync(path.join(import.meta.dirname, "fields.json"), "utf8"));

const from = fs.existsSync(snapshotPath) ? `--from-schema "${snapshotPath}"` : "--from-empty";
let sql = cp
  .execSync(`npx prisma migrate diff ${from} --to-schema "${schemaPath}" --script`, {
    cwd: prismaDir,
    stdio: ["ignore", "pipe", "inherit"],
  })
  .toString()
  .replace(/\r\n/g, "\n");

// table name -> set of nullable column names
const nullableColumns = new Map();
for (const info of Object.values(models)) {
  nullableColumns.set(info.table, new Set(info.nullable.map((f) => info.columns[f] ?? f)));
}
const filteredIndexNames = new Set();
const filteredIndex = (table, indexName, colList) => {
  const cols = colList.split(",").map((c) =>
    c
      .trim()
      .replace(/^\[|\]$/g, "")
      .replace(/\s+(ASC|DESC)$/i, "")
  );
  const nullable = cols.filter((c) => nullableColumns.get(table)?.has(c));
  if (!nullable.length) return null;
  filteredIndexNames.add(indexName);
  return (
    `CREATE UNIQUE NONCLUSTERED INDEX [${indexName}] ON [dbo].[${table}](${colList}) ` +
    `WHERE ${nullable.map((c) => `[${c}] IS NOT NULL`).join(" AND ")};`
  );
};

// 1) inline constraints inside CREATE TABLE
sql = sql.replace(/CREATE TABLE \[dbo\]\.\[(\w+)\] \(\n([\s\S]*?)\n\);/g, (stmt, table, body) => {
  const lines = body.split("\n");
  const after = [];
  const keep = lines.filter((l) => {
    const m = l.match(/^\s*CONSTRAINT \[(\w+)\] UNIQUE NONCLUSTERED \(([^)]*)\),?\s*$/);
    if (!m) return true;
    const idx = filteredIndex(table, m[1], m[2]);
    if (!idx) return true;
    after.push(idx);
    return false;
  });
  if (keep.length) keep[keep.length - 1] = keep[keep.length - 1].replace(/,\s*$/, "");
  return (
    `CREATE TABLE [dbo].[${table}] (\n${keep.join("\n")}\n);` +
    (after.length ? `\n\n${after.join("\n")}` : "")
  );
});
// 2) constraints added later
sql = sql.replace(
  /ALTER TABLE \[dbo\]\.\[(\w+)\] ADD CONSTRAINT \[(\w+)\] UNIQUE NONCLUSTERED \(([^)]*)\);/g,
  (stmt, table, idx, cols) => filteredIndex(table, idx, cols) ?? stmt
);
// 3) unique indexes
sql = sql.replace(
  /CREATE UNIQUE NONCLUSTERED INDEX \[(\w+)\] ON \[dbo\]\.\[(\w+)\]\(([^)]*)\);/g,
  (stmt, idx, table, cols) => filteredIndex(table, idx, cols) ?? stmt
);
// 4) dropping a key that a previous migration made a filtered index: it is an index, not a constraint
sql = sql.replace(/ALTER TABLE \[dbo\]\.\[(\w+)\] DROP CONSTRAINT \[(\w+_key)\];/g, (stmt, table, idx) => {
  const info = Object.values(models).find((m) => m.table === table);
  const wasNullable = info && idx.split("_").some((part) => nullableColumns.get(table)?.has(part));
  return wasNullable ? `DROP INDEX [${idx}] ON [dbo].[${table}];` : stmt;
});

if (printOnly) {
  process.stdout.write(sql);
  process.exit(0);
}
if (!/\b(CREATE|ALTER|DROP|EXEC|INSERT|UPDATE)\b/.test(sql)) {
  console.log("No schema changes since the last SQL Server migration.");
  process.exit(0);
}
const stamp = new Date().toISOString().replace(/[-:T]/g, "").slice(0, 14);
const dir = path.join(migrationsDir, `${stamp}_${name}`);
fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(path.join(dir, "migration.sql"), sql);
fs.writeFileSync(path.join(migrationsDir, "migration_lock.toml"), 'provider = "mssql"\n'); // Prisma's name for it here
fs.copyFileSync(schemaPath, snapshotPath);
console.log(
  `Wrote ${path.relative(prismaDir, dir)}/migration.sql (${filteredIndexNames.size} unique keys as filtered indexes). ` +
    "Review it and add any data changes by hand."
);
