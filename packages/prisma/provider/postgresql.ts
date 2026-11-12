// Database provider: PostgreSQL (the upstream Cal.diy default).
// selected.ts re-exports this module or ./sqlserver, depending on DATABASE_PROVIDER at generate time.
import { PrismaPg } from "@prisma/adapter-pg";
import { Pool } from "pg";
import { PrismaClient as GeneratedPrismaClient } from "../generated/prisma/client.ts";
import type { DatabaseProviderModule } from "./types.ts";

export const DATABASE_PROVIDER = "postgresql" as const;

export const PrismaClient = GeneratedPrismaClient;

export const createAdapter: DatabaseProviderModule["createAdapter"] = (connectionString, options) => {
  if (options?.pool) {
    const pool = new Pool({
      connectionString,
      max: options.pool.max,
      idleTimeoutMillis: options.pool.idleTimeoutMillis ?? 300000,
    });
    return { adapter: new PrismaPg(pool), close: () => pool.end() };
  }
  return { adapter: new PrismaPg({ connectionString }), close: async () => undefined };
};

export const withProviderExtensions: DatabaseProviderModule["withProviderExtensions"] = (client) => client;
