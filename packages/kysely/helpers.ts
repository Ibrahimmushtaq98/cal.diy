// JSON sub-query helpers for whichever database DATABASE_PROVIDER selects. Import these instead of
// kysely/helpers/postgres so the same query builds on PostgreSQL and SQL Server.

import { getConfiguredDatabaseProvider } from "@calcom/prisma/provider/types";
import type { Expression, RawBuilder, Simplify } from "kysely";
import * as mssql from "kysely/helpers/mssql";
import * as postgres from "kysely/helpers/postgres";

const helpers = getConfiguredDatabaseProvider() === "sqlserver" ? mssql : postgres;

export function jsonArrayFrom<O>(expr: Expression<O>): RawBuilder<Simplify<O>[]> {
  return helpers.jsonArrayFrom(expr as never) as RawBuilder<Simplify<O>[]>;
}

export function jsonObjectFrom<O>(expr: Expression<O>): RawBuilder<Simplify<O> | null> {
  return helpers.jsonObjectFrom(expr as never) as RawBuilder<Simplify<O> | null>;
}
