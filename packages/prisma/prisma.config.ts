import path from "node:path";
import process from "node:process";
import { config as loadEnv } from "dotenv";
import { defineConfig } from "prisma/config";
import { getConfiguredDatabaseProvider } from "./provider/types";

// Prisma 7 no longer reads .env on its own. The CLI runs from packages/prisma; the env lives at the repo root.
loadEnv({ path: path.resolve(__dirname, "../../.env"), quiet: true });

// DATABASE_PROVIDER picks the schema and migrations the CLI works on. Unset means PostgreSQL.
// The SQL Server schema is generated from schema.prisma (yarn sqlserver:schema) and has its own migrations.
const sqlServer = getConfiguredDatabaseProvider() === "sqlserver";

export default defineConfig({
  schema: sqlServer ? "sqlserver/schema.prisma" : "schema.prisma",
  migrations: {
    path: sqlServer ? "sqlserver/migrations" : "migrations",
    seed: "yarn seed-basic",
  },
  // Used by the CLI (migrate, db push, studio). Migrations need a direct connection, not a pooler.
  datasource: {
    url: process.env.DATABASE_DIRECT_URL || process.env.DATABASE_URL || "",
  },
});
