// Every file with raw SQL must be listed here with how it runs on SQL Server (DATABASE_PROVIDER=sqlserver).
// Raw SQL skips Prisma, so the Postgres SQL in it runs as is. When an upstream merge adds raw SQL to a new
// file this test fails: check the query on SQL Server (see sqlserver/README.md, "Raw SQL") and add the
// file here. A listed file whose SQL changed upstream is not caught, so review their diffs when merging.
import fs from "node:fs";
import path from "node:path";
import { describe, expect, it } from "vitest";

const RAW_SQL_FILES: Record<string, string> = {
  // the same SQL runs on both databases
  "packages/features/users/repositories/UserRepository.ts": "portable",
  "packages/lib/apps/getInstallCountPerApp.ts": "portable",
  "packages/prisma/is-prisma-available-check.ts": "portable",
  "packages/trpc/server/routers/viewer/availability/team/listTeamAvailability.handler.ts": "portable",
  "packages/trpc/server/routers/viewer/bookings/get.handler.ts": "portable; Kysely parts via MssqlCompatPlugin",
  "packages/trpc/server/routers/viewer/eventTypes/listWithTeam.handler.ts": "portable",
  // isSqlServer() picks a T-SQL version
  "packages/features/bookings/lib/handleSeats/create/createNewSeat.ts": "inline T-SQL branch",
  "packages/features/bookings/repositories/BookingRepository.ts": "BookingRepository.sqlserver.ts",
  "packages/features/bookings/repositories/BookingRepository.sqlserver.ts": "T-SQL",
  "packages/features/eventtypes/lib/getEventTypesPublic.ts": "getEventTypesPublic.sqlserver.ts",
  "packages/features/eventtypes/lib/getEventTypesPublic.sqlserver.ts": "T-SQL",
  "packages/features/flags/features.repository.ts": "sqlserver-queries.ts",
  "packages/features/flags/repositories/PrismaTeamFeatureRepository.ts": "sqlserver-queries.ts",
  "packages/features/flags/repositories/PrismaUserFeatureRepository.ts": "sqlserver-queries.ts",
  "packages/features/flags/sqlserver-queries.ts": "T-SQL",
  "packages/features/webhooks/lib/repository/WebhookRepository.ts": "WebhookRepository.sqlserver.ts",
  "packages/features/webhooks/lib/repository/WebhookRepository.sqlserver.ts": "T-SQL",
  // not ported: nothing calls them
  "packages/features/data-table/lib/server.ts": "unused: makeSqlCondition has no callers (= ANY, ILIKE)",
  "packages/kysely/utils/json/traverse/index.ts": "unused: traverseJSON has no callers (-> operator)",
  "packages/testing/src/lib/__mocks__/prisma.ts": "test mock",
};

const RAW_SQL = /\$queryRaw|\$executeRaw|Prisma\.sql`|Prisma\.raw\(|\bsql`|\bsql<[^>\n]*>`/;
const SKIP_DIRS = new Set(["node_modules", "dist", ".next", ".turbo", "generated", "migrations", "build", "out"]);
const repoRoot = path.resolve(__dirname, "../../..");

function* sourceFiles(dir: string): Generator<string> {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      if (!SKIP_DIRS.has(entry.name) && !entry.name.startsWith(".")) yield* sourceFiles(path.join(dir, entry.name));
    } else if (/\.tsx?$/.test(entry.name) && !/\.(test|spec|integration-test|e2e)\.tsx?$/.test(entry.name)) {
      yield path.join(dir, entry.name);
    }
  }
}

describe("raw SQL on SQL Server", () => {
  const found = new Set<string>();
  for (const top of ["apps", "packages"]) {
    for (const file of sourceFiles(path.join(repoRoot, top))) {
      if (RAW_SQL.test(fs.readFileSync(file, "utf8"))) found.add(path.relative(repoRoot, file).split(path.sep).join("/"));
    }
  }

  it("every file with raw SQL is reviewed for SQL Server", () => {
    expect([...found].filter((f) => !(f in RAW_SQL_FILES)).sort()).toEqual([]);
  });

  it("the list has no files that lost their raw SQL", () => {
    expect(Object.keys(RAW_SQL_FILES).filter((f) => !found.has(f)).sort()).toEqual([]);
  });
});
