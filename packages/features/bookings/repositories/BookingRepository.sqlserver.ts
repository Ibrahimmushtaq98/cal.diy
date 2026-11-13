// T-SQL versions of raw queries in BookingRepository.ts, used when DATABASE_PROVIDER=sqlserver.
// Keep them in step with the Postgres queries there.
import type { PrismaClient } from "@calcom/prisma";
import { Prisma } from "@calcom/prisma/client";

export async function getTotalBookingDurationSqlServer(
  prisma: Pick<PrismaClient, "$queryRaw">,
  { eventId, startDate, endDate, rescheduleUid }: { eventId: number; startDate: Date; endDate: Date; rescheduleUid?: string }
): Promise<number> {
  const [row] = await prisma.$queryRaw<[{ totalMinutes: number | null }]>(Prisma.sql`
    SELECT SUM(CAST(DATEDIFF_BIG(SECOND, "startTime", "endTime") AS float) / 60) AS "totalMinutes"
    FROM "Booking"
    WHERE "status" = 'ACCEPTED'
      AND "eventTypeId" = ${eventId}
      AND "startTime" >= ${startDate}
      AND "endTime" <= ${endDate}
      ${rescheduleUid ? Prisma.sql`AND "uid" != ${rescheduleUid}` : Prisma.empty}
  `);
  return Number(row?.totalMinutes ?? 0);
}
