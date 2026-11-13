// T-SQL version of WebhookRepository.getSubscribersRaw, used when DATABASE_PROVIDER=sqlserver. Keep it
// in step with the Postgres query there. On SQL Server "eventTriggers" is a JSON array in text, so the
// trigger check uses OPENJSON, and the branches for missing parameters are left out instead of being
// guarded by "param IS NOT NULL".
import type { PrismaClient } from "@calcom/prisma";
import { Prisma } from "@calcom/prisma/client";
import type { WebhookTriggerEvents } from "@calcom/prisma/enums";

export async function getSubscribersRawSqlServer<Row extends { eventTriggers: WebhookTriggerEvents[] }>(
  prisma: Pick<PrismaClient, "$queryRaw">,
  params: {
    userId?: number | null;
    eventTypeId?: number | null;
    managedParentEventTypeId?: number | null;
    teamIds?: number[];
    oAuthClientId?: string | null;
    triggerEvent: WebhookTriggerEvents;
  }
): Promise<Row[]> {
  const { userId, eventTypeId, managedParentEventTypeId, teamIds, oAuthClientId, triggerEvent } = params;
  const branch = (priority: number, where: Prisma.Sql) => Prisma.sql`
    SELECT id, "subscriberUrl", "payloadTemplate", "appId", secret, time, "timeUnit", "eventTriggers", version,
      ${Prisma.raw(String(priority))} AS priority
    FROM "Webhook"
    WHERE active = 1
      AND EXISTS (SELECT 1 FROM OPENJSON("eventTriggers") WHERE [value] = ${triggerEvent})
      AND ${where}`;

  const branches = [branch(1, Prisma.sql`platform = 1`)];
  if (userId != null) branches.push(branch(2, Prisma.sql`"userId" = ${userId} AND platform = 0`));
  if (eventTypeId != null) branches.push(branch(3, Prisma.sql`"eventTypeId" = ${eventTypeId} AND platform = 0`));
  if (managedParentEventTypeId != null)
    branches.push(branch(4, Prisma.sql`"eventTypeId" = ${managedParentEventTypeId} AND platform = 0`));
  if (teamIds?.length)
    branches.push(branch(5, Prisma.sql`"teamId" IN (${Prisma.join(teamIds)}) AND platform = 0`));
  if (oAuthClientId != null)
    branches.push(branch(6, Prisma.sql`"platformOAuthClientId" = ${oAuthClientId} AND platform = 0`));

  const rows = await prisma.$queryRaw<(Omit<Row, "eventTriggers"> & { eventTriggers: string })[]>(
    Prisma.sql`${Prisma.join(branches, " UNION ALL ")} ORDER BY priority, id`
  );
  return rows.map((row) => ({ ...row, eventTriggers: JSON.parse(row.eventTriggers || "[]") }) as Row);
}
