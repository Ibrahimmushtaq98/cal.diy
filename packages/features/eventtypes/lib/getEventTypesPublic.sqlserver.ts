// T-SQL version of the query in getEventTypesPublic.ts, used when DATABASE_PROVIDER=sqlserver. Keep it
// in step with the Postgres query there. Json columns come back as text, so they are parsed here.
import type { PrismaClient } from "@calcom/prisma";
import { Prisma } from "@calcom/prisma/client";

const columns = Prisma.sql`"EventType"."id", "EventType"."title", "EventType"."description",
  "EventType"."position", "EventType"."length", "EventType"."schedulingType",
  "EventType"."recurringEvent", "EventType"."slug", "EventType"."hidden",
  "EventType"."price", "EventType"."currency",
  "EventType"."lockTimeZoneToggleOnBookingPage", "EventType"."lockedTimeZone", "EventType"."requiresConfirmation",
  "EventType"."requiresBookerEmailVerification", "EventType"."metadata",
  "EventType"."canSendCalVideoTranscriptionEmails", "EventType"."seatsPerTimeSlot"`;

const parseJson = (value: unknown) => (typeof value === "string" ? JSON.parse(value) : value);

export async function getEventTypesWithHiddenSqlServer<Row>(
  prisma: Pick<PrismaClient, "$queryRaw">,
  userId: number
): Promise<Row[]> {
  const rows = await prisma.$queryRaw<Record<string, unknown>[]>(Prisma.sql`
    SELECT data."id", data."title", data."description", data."length", data."schedulingType",
      data."recurringEvent", data."slug", data."hidden", data."price", data."currency",
      data."lockTimeZoneToggleOnBookingPage", data."lockedTimeZone", data."requiresConfirmation", data."requiresBookerEmailVerification",
      data."metadata", data."canSendCalVideoTranscriptionEmails"
    FROM (
      SELECT ${columns}
      FROM "EventType"
      WHERE "EventType"."teamId" IS NULL AND "EventType"."userId" = ${userId}
      UNION
      SELECT ${columns}
      FROM "EventType"
      WHERE "EventType"."teamId" IS NULL
        AND "EventType"."userId" IS NOT NULL
        AND "EventType"."id" IN (
          SELECT "uet1"."A" FROM "_user_eventtype" AS "uet1"
          INNER JOIN "users" AS "u1" ON "u1"."id" = "uet1"."B"
          WHERE "u1"."id" = ${userId} AND "uet1"."A" IS NOT NULL
        )
    ) data
    ORDER BY data."position" DESC, data."id" ASC`);
  return rows.map(
    (row) => ({ ...row, metadata: parseJson(row.metadata), recurringEvent: parseJson(row.recurringEvent) }) as Row
  );
}
