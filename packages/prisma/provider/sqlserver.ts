// Database provider: Microsoft SQL Server (Labourly addition, not in upstream Cal.diy).
// selected.ts re-exports this module when DATABASE_PROVIDER=sqlserver at generate time.
//
// The client comes from the generated SQL Server schema (sqlserver/schema.prisma) but is typed as the
// Postgres client, which is what the app is written against; sqlserverExtension makes the runtime
// shapes match (Json/list fields, filters). See packages/prisma/sqlserver/README.md.
import { PrismaMssql } from "@prisma/adapter-mssql";
import type { PrismaClient as PgPrismaClient } from "../generated/prisma/client";
import { PrismaClient as GeneratedPrismaClient } from "../generated/prisma-sqlserver/client";
import { sqlServerExtension } from "../sqlserver/extension";
import type { DatabaseProviderModule } from "./types";

export const DATABASE_PROVIDER = "sqlserver" as const;

export const PrismaClient = GeneratedPrismaClient as unknown as typeof PgPrismaClient;

export const createAdapter: DatabaseProviderModule["createAdapter"] = (connectionString, options) => {
  let url = connectionString;
  if (options?.pool && !/;\s*connectionLimit\s*=/i.test(url))
    url = `${url};connectionLimit=${options.pool.max}`;
  return { adapter: new PrismaMssql(url), close: async () => undefined };
};

export const withProviderExtensions: DatabaseProviderModule["withProviderExtensions"] = (client) =>
  sqlServerExtension(client);
