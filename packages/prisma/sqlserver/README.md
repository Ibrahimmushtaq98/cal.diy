# SQL Server support

Cal.diy runs on PostgreSQL by default. Set `DATABASE_PROVIDER=sqlserver` to run it on SQL Server instead.
Leaving it unset (or `postgresql`) changes nothing for existing setups.

## Setup

```env
DATABASE_PROVIDER=sqlserver
DATABASE_URL="sqlserver://localhost:1433;database=calendso;user=sa;password=...;encrypt=true;trustServerCertificate=true"
DATABASE_DIRECT_URL="sqlserver://localhost:1433;database=calendso;user=sa;password=...;encrypt=true;trustServerCertificate=true"
```

1. Create the database with a case-insensitive collation (Cal.diy's `mode: "insensitive"` searches rely on it):
   `CREATE DATABASE calendso COLLATE SQL_Latin1_General_CP1_CI_AS;`
2. `yarn install` (or `yarn prisma generate`) with `DATABASE_PROVIDER` set. The provider is picked at generate
   time; the app refuses to start if `DATABASE_PROVIDER` at runtime differs.
3. `yarn workspace @calcom/prisma prisma migrate deploy` applies `sqlserver/migrations`.
4. Optional: `yarn workspace @calcom/prisma seed-basic` for the demo users.

SQL Server 2016 or later is needed (`OPENJSON`, `CREATE OR ALTER`, `DROP ... IF EXISTS`).

## How it works

| Piece | Where |
| --- | --- |
| Generated SQL Server schema | `sqlserver/generate-schema.mjs` writes `sqlserver/schema.prisma`, `fields.json`, `emulated-relations.sql` from the Postgres `schema.prisma`, which stays upstream's source of truth |
| Both Prisma clients | `generated/prisma` (Postgres) and `generated/prisma-sqlserver`; `provider/selected.ts` (generated, not committed) re-exports the one `DATABASE_PROVIDER` picks |
| Driver adapter | `provider/postgresql.ts` (`@prisma/adapter-pg`), `provider/sqlserver.ts` (`@prisma/adapter-mssql`) |
| Json, lists, enums | Stored as NVARCHAR; `sqlserver/extension.ts` converts them in Prisma queries so app code sees the same values as on Postgres |
| Kysely | `@calcom/kysely/create` picks `MssqlDialect`; `MssqlCompatPlugin` rewrites `limit`, `ilike` and Postgres cast types |
| Raw SQL | Portable SQL, or a T-SQL version chosen with `isSqlServer()` (see below) |
| Triggers and views | `sqlserver/migrations/*_database_logic` (booking denormalization, membership role, Insights views) |

Data differences from Postgres:

- **Enums** are stored as their key names (`ACCEPTED`), not the `@map` values (`accepted`). Prisma code is
  unaffected. In raw SQL and Kysely only the case differs, which the collation ignores, except
  `SchedulingType.ROUND_ROBIN` (`roundRobin`) and `RedirectType` (`user-event-type`, `team-event-type`).
- **Json and list columns** hold JSON text. Raw SQL reading them gets a string; parse it.
- **Case-insensitive unique keys**: `Foo@x.com` and `foo@x.com` collide (Cal.diy lower-cases emails anyway).
- **Cascades**: SQL Server allows only one cascade path to a table. 122 of the schema's cascading relations are
  real foreign keys; the other 50 have no foreign key and are done by `AFTER DELETE` triggers
  (`emulated-relations.sql`). Those relations are not enforced on insert.
- **Unique keys on nullable columns** are filtered indexes (`WHERE col IS NOT NULL`), so any number of rows
  can leave them empty, as on Postgres.

**API v2** (`apps/api/v2`) creates its Prisma and Kysely clients through the same switch, but it has only been
run on Postgres. Its booking logic comes from the `@calcom/platform-libraries` bundle, which bundles its own
`@calcom/prisma`; building that for SQL Server (likely adding `@prisma/adapter-mssql`, `tedious` and `kysely`
to its Vite externals) is untested.

Not supported on SQL Server (the extension throws `SqlServerUnsupportedError` where it can tell):
list `push` updates, Json path filters (`path`, `array_contains`, ...), and `createMany({ skipDuplicates })`
(the flag is dropped, so duplicates fail).

## After merging from upstream

1. `yarn workspace @calcom/prisma sqlserver:schema` regenerates the SQL Server schema from `schema.prisma`.
   `node sqlserver/generate-schema.mjs --check` fails when it is out of date (use it in CI).
2. Schema changed? `node sqlserver/new-migration.mjs <name>` writes the next SQL Server migration by diffing
   against `sqlserver/migrations/schema.snapshot.prisma` (no shadow database needed). Review it.
3. Upstream migrations that insert or update data, or add triggers, functions or views, are not carried over:
   port them by hand into the new SQL Server migration (T-SQL triggers work on the `inserted`/`deleted` sets
   and need `EXEC(N'...')` in a migration; there are no `BEFORE` triggers).
4. `yarn vitest run packages/prisma/sqlserver/raw-sql.test.ts` fails if new raw SQL appeared. Review the
   diffs of the files listed there too: a changed Postgres query needs the same change in its T-SQL version.

## Raw SQL

Raw SQL bypasses Prisma, so the Postgres SQL in it runs unchanged. `tedious` turns on `QUOTED_IDENTIFIER`,
so `"Table"."column"` works on both databases. Common fixes:

| Postgres | SQL Server |
| --- | --- |
| `"public"."users"` | `"users"` (portable) |
| `= true` / `= FALSE` | `= ${true}` parameter (portable) or `= 1` |
| `COUNT(*)::integer` | `CAST(COUNT(*) AS integer)` (portable) |
| `LIMIT 1` | `TOP 1` |
| `WITH RECURSIVE` | `WITH` (no `DISTINCT` in the recursive member) |
| `x = ANY(${array})` | `x IN (${Prisma.join(array)})` |
| `x = ANY("listColumn")` | `EXISTS (SELECT 1 FROM OPENJSON("listColumn") WHERE [value] = x)` |
| `ILIKE` | `LIKE` (collation is case-insensitive) |
| `FOR UPDATE` | `WITH (UPDLOCK, ROWLOCK)` after the table name |
| `EXTRACT(EPOCH FROM (b - a))` | `DATEDIFF_BIG(SECOND, a, b)` |
| `NOW()` | `SYSUTCDATETIME()` |

Write a portable query when the change is small. Otherwise put the T-SQL version in a `*.sqlserver.ts` file
next to the original and pick it with `isSqlServer()` from `@calcom/prisma/provider/types`, so the upstream
file only gains a couple of lines.

## Local test database

```sh
docker run -d --name caldiy-mssql -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD='<strong password>' \
  -p 1434:1433 mcr.microsoft.com/mssql/server:2022-latest
```

Then create the database with the collation above and follow Setup with `localhost:1434`.
