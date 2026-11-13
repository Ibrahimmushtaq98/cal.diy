// Builds a Kysely client for DATABASE_PROVIDER (postgresql by default, or sqlserver).
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
import { MssqlCompatPlugin } from "./mssql-compat-plugin";
import type { DB } from "./types";

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

function createDialect(connectionString: string, maxConnections?: number): Dialect {
  if (getConfiguredDatabaseProvider() === "sqlserver") {
    return new MssqlDialect({
      tarn: { ...Tarn, options: { min: 0, max: maxConnections ?? 10 } },
      tedious: {
        ...Tedious,
        connectionFactory: () => new Tedious.Connection(tediousConfigFromUrl(connectionString)),
      },
    });
  }
  return new PostgresDialect({ pool: new Pool({ connectionString, max: maxConnections }) });
}

export function createKysely(connectionString: string, options?: { maxConnections?: number }): Kysely<DB> {
  return new Kysely<DB>({
    dialect: createDialect(connectionString, options?.maxConnections),
    plugins: [
      new ParseJSONResultsPlugin(),
      new DeduplicateJoinsPlugin(),
      ...(getConfiguredDatabaseProvider() === "sqlserver" ? [new MssqlCompatPlugin()] : []),
    ],
  });
}
