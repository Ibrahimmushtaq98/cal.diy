import process from "node:process";
import { getConfiguredDatabaseProvider } from "@calcom/prisma/provider/types";
import {
  DeduplicateJoinsPlugin,
  type Dialect,
  Kysely,
  MssqlDialect,
  ParseJSONResultsPlugin,
  PostgresDialect,
} from "kysely";
import { Pool } from "pg";
import * as Tarn from "tarn";
import * as Tedious from "tedious";
import type { Booking, DB } from "./types.ts";

export type { Booking, DB };

const connectionString = process.env.DATABASE_URL ?? "postgresql://postgres:@localhost:5450/calendso";

/**
 * Turns a Prisma SQL Server URL (sqlserver://host:port;database=x;user=u;password=p;encrypt=true;...)
 * into tedious connection options.
 */
export function tediousConfigFromUrl(url: string): Tedious.ConnectionConfiguration {
  const [hostPart, ...params] = url.replace(/^sqlserver:\/\//, "").split(";");
  const [server, port] = hostPart.split(":");
  const p: Record<string, string> = {};
  for (const part of params) {
    const i = part.indexOf("=");
    if (i > 0)
      p[part.slice(0, i).trim().toLowerCase()] = part
        .slice(i + 1)
        .trim()
        .replace(/^\{(.*)\}$/, "$1");
  }
  const flag = (k: string, d: boolean) => (p[k] === undefined ? d : p[k].toLowerCase() === "true");
  return {
    server,
    authentication: { type: "default", options: { userName: p.user ?? p.username, password: p.password } },
    options: {
      port: port ? Number(port) : 1433,
      database: p.database ?? p["initial catalog"],
      encrypt: flag("encrypt", true),
      trustServerCertificate: flag("trustservercertificate", false),
    },
  };
}

function createDialect(): Dialect {
  if (getConfiguredDatabaseProvider() === "sqlserver") {
    return new MssqlDialect({
      tarn: { ...Tarn, options: { min: 0, max: 10 } },
      tedious: {
        ...Tedious,
        connectionFactory: () => new Tedious.Connection(tediousConfigFromUrl(connectionString)),
      },
    });
  }
  return new PostgresDialect({ pool: new Pool({ connectionString }) });
}

const db = new Kysely<DB>({
  dialect: createDialect(),
  plugins: [new ParseJSONResultsPlugin(), new DeduplicateJoinsPlugin()],
});

export default db;
