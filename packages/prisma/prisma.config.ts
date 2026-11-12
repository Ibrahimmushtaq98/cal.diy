import path from "node:path";
import { config as loadEnv } from "dotenv";
import { defineConfig } from "prisma/config";

// Prisma 7 no longer reads .env on its own. The CLI runs from packages/prisma; the env lives at the repo root.
loadEnv({ path: path.resolve(__dirname, "../../.env"), quiet: true });

export default defineConfig({
  schema: "schema.prisma",
  migrations: {
    path: "migrations",
    seed: "yarn seed-basic",
  },
  // Used by the CLI (migrate, db push, studio). Migrations need a direct connection, not a pooler.
  datasource: {
    url: process.env.DATABASE_DIRECT_URL || process.env.DATABASE_URL || "",
  },
});
