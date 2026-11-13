import process from "node:process";
import type { Prisma, PrismaClient } from "../generated/prisma/client";

export type DatabaseProvider = "postgresql" | "sqlserver";

export type AdapterOptions = {
  /** Use a connection pool of this size (Postgres) or cap the driver's pool at it (SQL Server). */
  pool?: { max: number; idleTimeoutMillis?: number };
};

/**
 * What every database provider module exports. The app is typed against the Postgres client;
 * the SQL Server module returns a client whose runtime behaviour matches it (see sqlserver/extension.ts).
 */
export type DatabaseProviderModule = {
  DATABASE_PROVIDER: DatabaseProvider;
  createAdapter: (
    connectionString: string,
    options?: AdapterOptions
  ) => { adapter: NonNullable<Prisma.PrismaClientOptions["adapter"]>; close: () => Promise<void> };
  withProviderExtensions: (client: PrismaClient) => PrismaClient;
};

/** Reads DATABASE_PROVIDER. Unset means PostgreSQL, so existing setups keep working unchanged. */
export function getConfiguredDatabaseProvider(value = process.env.DATABASE_PROVIDER): DatabaseProvider {
  const v = (value ?? "").trim().toLowerCase();
  if (v === "" || v === "postgresql" || v === "postgres") return "postgresql";
  if (v === "sqlserver" || v === "mssql") return "sqlserver";
  throw new Error(`DATABASE_PROVIDER must be "postgresql" or "sqlserver", got "${value}"`);
}

/** True when DATABASE_PROVIDER selects SQL Server. Raw SQL written for Postgres checks this to pick its T-SQL version. */
export function isSqlServer(): boolean {
  return getConfiguredDatabaseProvider() === "sqlserver";
}
