#!/usr/bin/env node
// Generates the SQL Server copy of the Prisma schema from packages/prisma/schema.prisma.
//
// schema.prisma (Postgres) stays the source of truth and keeps matching upstream Cal.diy. This script
// rewrites it for SQL Server, which Prisma supports with fewer features:
//   - Json fields      -> String @db.NVarChar(Max), holding JSON text
//   - list fields      -> String @db.NVarChar(Max), holding a JSON array
//   - enum fields      -> String, holding the enum key (the same string the Prisma enums hold in TS)
//   - Postgres native types -> SQL Server equivalents
//   - plain String     -> NVarChar(Max), unless the column is part of a key or index
//   - referential actions: SQL Server allows only one cascade path between two tables and no
//     cycles, so the Cascade/SetNull actions that would break that become NoAction here and are
//     emulated at runtime (emulatedRelations in fields.json).
//
// Outputs (all generated, do not edit by hand):
//   sqlserver/schema.prisma  - the schema the SQL Server client and migrations are built from
//   sqlserver/fields.json    - what the runtime layer needs to make SQL Server look like Postgres
//
// usage: node sqlserver/generate-schema.mjs [--check]
//   --check exits 1 when the committed files are out of date (for CI).
import fs from "node:fs";
import path from "node:path";
import process from "node:process";

const root = path.resolve(import.meta.dirname, "..");
const inPath = path.join(root, "schema.prisma");
const outPath = path.join(import.meta.dirname, "schema.prisma");
const mapPath = path.join(import.meta.dirname, "fields.json");

const src = fs.readFileSync(inPath, "utf8").replace(/\r\n/g, "\n");
const lines = src.split("\n");

// ---- pass 1: enums, model and view names ----
const enums = {};
const models = new Set();
{
  let cur = null;
  for (const l of lines) {
    let m;
    if ((m = l.match(/^enum (\w+) \{/))) {
      cur = m[1];
      enums[cur] = [];
      continue;
    }
    if ((m = l.match(/^(model|view) (\w+) \{/))) models.add(m[2]);
    if (cur) {
      if (/^\}/.test(l)) {
        cur = null;
        continue;
      }
      const v = l.trim().match(/^(\w+)\b/);
      if (v && !l.trim().startsWith("//")) enums[cur].push(v[1]);
    }
  }
}

// ---- pass 2: rewrite each block ----
const out = [];
// model -> { table, json: [field], list: {field: elementType}, enum: {field: enumName}, columns: {field: column}, nullable: [field], relations: {field: model} }
const fields = {};

function indexedFields(body) {
  const set = new Set();
  for (const l of body) {
    const t = l.trim();
    let m;
    if ((m = t.match(/^(\w+)\s+\S+.*@(id|unique)\b/))) set.add(m[1]);
    for (const mm of t.matchAll(/@@(?:id|unique|index)\(\s*(?:fields:\s*)?\[([^\]]*)\]/g))
      mm[1].split(",").forEach((f) => set.add(f.trim().replace(/\(.*$/, "")));
    for (const mm of t.matchAll(/fields:\s*\[([^\]]*)\]/g))
      mm[1].split(",").forEach((f) => set.add(f.trim()));
  }
  return set;
}

function mapNativeTypes(rest) {
  return rest
    .replace(/@db\.Uuid\b/g, "@db.UniqueIdentifier")
    .replace(/@db\.Text\b/g, "@db.NVarChar(Max)")
    .replace(/@db\.Timestamptz(\(\d+\))?/g, "@db.DateTimeOffset")
    .replace(/@db\.Timestamp(\(\d+\))?/g, "@db.DateTime2")
    .replace(/@db\.Time(\(\d+\))?/g, "@db.Time")
    .replace(/@db\.VarChar\((\d+)\)/g, "@db.NVarChar($1)")
    .replace(/@db\.Integer\b/g, "@db.Int")
    .replace(/@db\.DoublePrecision\b/g, "@db.Float");
}

function convertField(line, indexed, info) {
  const m = line.match(/^(\s+)(\w+)(\s+)(\w+)(\[\]|\?)?(.*)$/);
  if (!m) return line;
  const [, ind, name, sp, type, mod = ""] = m;
  let rest = m[6];
  if (models.has(type)) {
    info.relations[name] = type;
    return line;
  }
  const col = rest.match(/@map\(\s*(?:name:\s*)?"([^"]+)"\s*\)/);
  info.columns[name] = col ? col[1] : name;
  if (mod === "?") info.nullable.push(name);
  const opt = mod === "?" ? "?" : "";
  rest = mapNativeTypes(rest);

  if (mod === "[]") {
    info.list[name] = type;
    rest = rest.replace(/@default\(\[(.*?)\]\)/, (_, inner) => {
      const vals = inner.trim() ? inner.split(",").map((s) => s.trim()) : [];
      const js = vals.map((v) => (enums[type] ? v : JSON.parse(v)));
      return `@default(${JSON.stringify(JSON.stringify(js))})`;
    });
    // Prisma lists are required and start empty when a create leaves them out
    if (!/@default\(/.test(rest)) rest = ` @default("[]")${rest}`;
    if (!/@db\./.test(rest)) rest = ` @db.NVarChar(Max)${rest}`;
    return `${ind}${name}${sp}String${rest}`;
  }
  if (type === "Json") {
    info.json.push(name);
    if (!/@db\./.test(rest)) rest = ` @db.NVarChar(Max)${rest}`;
    return `${ind}${name}${sp}String${opt}${rest}`;
  }
  if (enums[type]) {
    info.enum[name] = type;
    rest = rest.replace(/@default\((\w+)\)/, (_, v) => `@default("${v}")`);
    if (!/@db\./.test(rest)) rest = ` @db.NVarChar(100)${rest}`;
    return `${ind}${name}${sp}String${opt}${rest}`;
  }
  if (type === "String" && !/@db\./.test(rest) && !indexed.has(name)) {
    return `${ind}${name}${sp}String${opt} @db.NVarChar(Max)${rest}`;
  }
  return `${ind}${name}${sp}${type}${mod}${rest}`;
}

let block = null;
let blockLines = [];
for (const l of lines) {
  let m;
  if (!block) {
    if (l.match(/^enum (\w+) \{/)) {
      block = { kind: "enum" };
      continue;
    }
    if ((m = l.match(/^(model|view|datasource|generator) (\w+) \{/))) {
      block = { kind: m[1], name: m[2] };
      blockLines = [l];
      continue;
    }
    out.push(l);
    continue;
  }
  if (block.kind === "enum") {
    if (/^\}/.test(l)) block = null;
    continue;
  }
  blockLines.push(l);
  if (!/^\}/.test(l)) continue;

  if (block.kind === "datasource") {
    out.push("datasource db {", '  provider = "sqlserver"', "}");
  } else if (block.kind === "generator") {
    // Only the runtime client is generated from this schema. The zod, kysely and enum generators are
    // type-only and keep coming from the Postgres schema, so both databases share one set of types.
    if (block.name === "client")
      out.push(
        ...blockLines.map((x) =>
          x.replace(/output(\s*)=\s*"[^"]*"/, 'output$1= "../generated/prisma-sqlserver"')
        )
      );
  } else {
    const body = blockLines.slice(1, -1);
    const indexed = indexedFields(body);
    const info = (fields[block.name] = {
      table: block.name,
      json: [],
      list: {},
      enum: {},
      columns: {},
      nullable: [],
      relations: {},
    });
    const tbl = body.map((x) => x.trim().match(/^@@map\(\s*(?:name:\s*)?"([^"]+)"\s*\)/)).find(Boolean);
    if (tbl) info.table = tbl[1];
    const converted = body.map((x) =>
      /^\s+\w+\s+\w+/.test(x) && !x.trim().startsWith("@@") && !x.trim().startsWith("//")
        ? convertField(x, indexed, info)
        : x
    );
    out.push(blockLines[0], ...converted, "}");
  }
  block = null;
  blockLines = [];
}

// ---- pass 3: referential actions ----
// SQL Server rejects cascade cycles and multiple cascade paths between two tables. Keep as many
// Cascade/SetNull actions in the database as that allows (Cascade first) and set the rest to
// NoAction; the runtime layer emulates those. onUpdate is NoAction everywhere: ids never change.
const relationEdges = [];
{
  let model = null;
  out.forEach((l, i) => {
    const mm = l.match(/^(model|view) (\w+)/);
    if (mm) model = mm[2];
    if (/^\}/.test(l)) model = null;
    const r = l.match(
      /^\s+(\w+)\s+(\w+)(\?)?\s+@relation\(([^)]*fields:\s*\[([^\]]*)\][^)]*references:\s*\[([^\]]*)\][^)]*)\)/
    );
    if (!r || !model) return;
    const [, field, parent, opt, inner, fks, refs] = r;
    const od = inner.match(/onDelete:\s*(\w+)/);
    relationEdges.push({
      i,
      child: model,
      field,
      parent,
      action: od ? od[1] : opt ? "SetNull" : "Restrict",
      fks: fks.split(",").map((s) => s.trim()),
      refs: refs.split(",").map((s) => s.trim()),
    });
  });
}
const kept = new Map();
const reach = (from) => {
  const seen = new Set([from]);
  const st = [from];
  while (st.length) for (const c of kept.get(st.pop()) || []) if (!seen.has(c)) seen.add(c), st.push(c);
  return seen;
};
const ancestors = (to) => {
  const seen = new Set([to]);
  const st = [to];
  while (st.length) {
    const n = st.pop();
    for (const [p, cs] of kept) if (cs.has(n) && !seen.has(p)) seen.add(p), st.push(p);
  }
  return seen;
};
const keptEdges = new Set();
const cascading = relationEdges
  .filter((e) => e.action === "Cascade" || e.action === "SetNull")
  .sort((a, b) => (a.action === b.action ? 0 : a.action === "Cascade" ? -1 : 1));
for (const e of cascading) {
  if (e.parent === e.child) continue; // SQL Server can't cascade a table onto itself
  const desc = reach(e.child);
  let ok = !desc.has(e.parent);
  if (ok)
    for (const a of ancestors(e.parent)) {
      const r = reach(a);
      for (const d of desc) if (r.has(d)) ok = false;
      if (!ok) break;
    }
  if (!ok) continue;
  if (!kept.has(e.parent)) kept.set(e.parent, new Set());
  kept.get(e.parent).add(e.child);
  keptEdges.add(e);
}
const emulated = [];
for (const e of relationEdges) {
  const base = out[e.i].replace(/,\s*onDelete:\s*\w+/, "").replace(/,\s*onUpdate:\s*\w+/, "");
  const keep = keptEdges.has(e);
  out[e.i] = base.replace(
    /@relation\(([^)]*)\)/,
    `@relation($1, onDelete: ${keep ? e.action : "NoAction"}, onUpdate: NoAction)`
  );
  if (!keep && (e.action === "Cascade" || e.action === "SetNull"))
    emulated.push({
      parent: e.parent,
      child: e.child,
      field: e.field,
      onDelete: e.action,
      fields: e.fks,
      references: e.refs,
    });
}

// ---- pass 4: triggers for the emulated relations ----
// The migrations leave out the foreign keys of emulated relations (new-migration.mjs) and add one
// AFTER DELETE trigger per parent table that does what Postgres' ON DELETE did. AFTER triggers also
// run for rows the database's own cascades delete, and a trigger's DELETE runs the child table's
// trigger in turn (nested triggers), so cascades chain like they do in Postgres. A table deleting
// its own children (Team.parent, EventType.parent) would need recursive triggers, so the trigger
// collects the whole subtree first.
const q = (s) => `[${s}]`;
const col = (model, field) => q(fields[model].columns[field] ?? field);
const tbl = (model) => `[dbo].${q(fields[model].table)}`;
const triggerName = (model) => `${fields[model].table}_emulated_on_delete`;
const byParent = new Map();
for (const r of emulated) byParent.set(r.parent, [...(byParent.get(r.parent) ?? []), r]);
const sqlString = (s) => `N'${s.replace(/'/g, "''")}'`;
const triggers = [...byParent.entries()]
  .sort(([a], [b]) => a.localeCompare(b))
  .map(([parent, rels]) => {
    const selfCascade = rels.filter((r) => r.child === parent && r.onDelete === "Cascade");
    for (const r of selfCascade)
      if (r.fields.length !== 1 || r.references.join() !== "id")
        throw new Error(`self-cascade ${parent}.${r.field}: only single-column relations to id are supported`);
    const source = selfCascade.length ? "@gone" : "deleted";
    const body = [];
    if (selfCascade.length) {
      // every row being removed: the deleted rows plus all their descendants
      body.push(
        "DECLARE @gone TABLE ([id] INT PRIMARY KEY);",
        `WITH tree AS (SELECT [id] FROM deleted UNION ALL ${selfCascade
          .map((r) => `SELECT c.[id] FROM ${tbl(parent)} c INNER JOIN tree t ON c.${col(parent, r.fields[0])} = t.[id]`)
          .join(" UNION ALL ")}) INSERT INTO @gone SELECT DISTINCT [id] FROM tree OPTION (MAXRECURSION 100);`
      );
    }
    for (const r of rels.filter((x) => !selfCascade.includes(x))) {
      const on = r.fields.map((f, i) => `c.${col(r.child, f)} = d.${col(parent, r.references[i])}`).join(" AND ");
      body.push(
        r.onDelete === "SetNull"
          ? `UPDATE c SET ${r.fields.map((f) => `c.${col(r.child, f)} = NULL`).join(", ")} FROM ${tbl(r.child)} c INNER JOIN ${source} d ON ${on}; -- ${r.child}.${r.field}`
          : `DELETE c FROM ${tbl(r.child)} c INNER JOIN ${source} d ON ${on}; -- ${r.child}.${r.field}`
      );
    }
    if (selfCascade.length)
      body.push(
        `DELETE p FROM ${tbl(parent)} p INNER JOIN @gone g ON p.[id] = g.[id]; -- ${selfCascade.map((r) => `${parent}.${r.field}`).join(", ")}`
      );
    const create = `CREATE TRIGGER [dbo].${q(triggerName(parent))} ON ${tbl(parent)} AFTER DELETE AS\nBEGIN\n  SET NOCOUNT ON;\n  ${body.join("\n  ")}\nEND`;
    return `EXEC(${sqlString(create)});`;
  });
const triggersOut =
  "-- GENERATED by packages/prisma/sqlserver/generate-schema.mjs. Do not edit.\n" +
  "-- ON DELETE behaviour SQL Server can't hold as foreign keys (see emulatedRelations in fields.json).\n" +
  "-- new-migration.mjs adds this to a migration whenever it changes.\n" +
  "DECLARE @drop NVARCHAR(MAX) = N'';\n" +
  "SELECT @drop += N'DROP TRIGGER [dbo].' + QUOTENAME(name) + N';' FROM sys.triggers WHERE name LIKE N'%[_]emulated[_]on[_]delete';\n" +
  "EXEC sp_executesql @drop;\n" +
  triggers.join("\n") +
  "\n";
const triggersPath = path.join(import.meta.dirname, "emulated-relations.sql");

const header =
  "// GENERATED by packages/prisma/sqlserver/generate-schema.mjs from ../schema.prisma. Do not edit.\n" +
  "// Run `yarn workspace @calcom/prisma sqlserver:schema` after changing ../schema.prisma.\n";
const schemaOut = header + out.join("\n");
const mapOut = JSON.stringify({ enums, models: fields, emulatedRelations: emulated }, null, 2) + "\n";

if (process.argv.includes("--check")) {
  const stale = [
    [outPath, schemaOut],
    [mapPath, mapOut],
    [triggersPath, triggersOut],
  ].filter(([p, c]) => !fs.existsSync(p) || fs.readFileSync(p, "utf8").replace(/\r\n/g, "\n") !== c);
  if (stale.length) {
    console.error(
      `SQL Server schema is out of date: ${stale.map(([p]) => path.relative(root, p)).join(", ")}. ` +
        "Run `yarn workspace @calcom/prisma sqlserver:schema`."
    );
    process.exit(1);
  }
  console.log("SQL Server schema is up to date.");
} else {
  fs.writeFileSync(outPath, schemaOut);
  fs.writeFileSync(mapPath, mapOut);
  fs.writeFileSync(triggersPath, triggersOut);
  const count = (k) =>
    Object.values(fields).reduce(
      (n, f) => n + (Array.isArray(f[k]) ? f[k].length : Object.keys(f[k]).length),
      0
    );
  console.log(
    `sqlserver/schema.prisma: ${models.size} models/views; json ${count("json")}, list ${count("list")}, enum ${count("enum")} fields; ` +
      `${keptEdges.size} cascades kept in the database, ${emulated.length} emulated`
  );
}
