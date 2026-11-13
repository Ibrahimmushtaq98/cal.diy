// T-SQL versions of the team-feature checks in features.repository.ts, PrismaTeamFeatureRepository.ts and
// PrismaUserFeatureRepository.ts, used when DATABASE_PROVIDER=sqlserver. Keep them in step with the
// Postgres queries there. T-SQL has no WITH RECURSIVE / LIMIT / boolean literals, and a recursive CTE
// member can't use DISTINCT.
import type { PrismaClient } from "@calcom/prisma";
import { Prisma } from "@calcom/prisma/client";

const teamHasFeature = (teamColumn: Prisma.Sql, slug: string) => Prisma.sql`
  CASE WHEN EXISTS (
    SELECT 1 FROM "TeamFeatures" tf
    WHERE tf."teamId" = ${teamColumn} AND tf."featureId" = ${slug} AND tf."enabled" = 1
  ) THEN 1 ELSE 0 END`;

/** Does a team the user belongs to, or one of its ancestors, have the feature enabled? */
export async function userBelongsToTeamWithFeatureSqlServer(
  prisma: Pick<PrismaClient, "$queryRaw">,
  userId: number,
  slug: string
): Promise<boolean> {
  const rows = await prisma.$queryRaw<unknown[]>(Prisma.sql`
    WITH TeamHierarchy AS (
      SELECT DISTINCT t.id, t."parentId", ${teamHasFeature(Prisma.sql`t.id`, slug)} AS has_feature
      FROM "Team" t
      INNER JOIN "Membership" m ON m."teamId" = t.id
      WHERE m."userId" = ${userId} AND m.accepted = 1

      UNION ALL

      SELECT p.id, p."parentId", ${teamHasFeature(Prisma.sql`p.id`, slug)} AS has_feature
      FROM "Team" p
      INNER JOIN TeamHierarchy c ON p.id = c."parentId"
      WHERE c.has_feature = 0
    )
    SELECT TOP 1 1 AS found FROM TeamHierarchy WHERE has_feature = 1
  `);
  return rows.length > 0;
}

/** Does a team the user belongs to have the feature enabled (direct membership only)? */
export async function userBelongsToTeamWithFeatureNonHierarchicalSqlServer(
  prisma: Pick<PrismaClient, "$queryRaw">,
  userId: number,
  slug: string
): Promise<boolean> {
  const rows = await prisma.$queryRaw<unknown[]>(Prisma.sql`
    SELECT TOP 1 1 AS found
    FROM "Team" t
    INNER JOIN "Membership" m ON m."teamId" = t.id
    WHERE m."userId" = ${userId}
      AND m.accepted = 1
      AND EXISTS (
        SELECT 1 FROM "TeamFeatures" tf
        WHERE tf."teamId" = t.id AND tf."featureId" = ${slug} AND tf."enabled" = 1
      )
  `);
  return rows.length > 0;
}

/** Does the team or one of its ancestors have the feature enabled? */
export async function teamOrAncestorHasFeatureSqlServer(
  prisma: Pick<PrismaClient, "$queryRaw">,
  teamId: number,
  featureId: string
): Promise<boolean> {
  const rows = await prisma.$queryRaw<unknown[]>(Prisma.sql`
    WITH TeamHierarchy AS (
      SELECT t.id, t."parentId", ${teamHasFeature(Prisma.sql`t.id`, featureId)} AS has_feature
      FROM "Team" t
      WHERE t.id = ${teamId}

      UNION ALL

      SELECT p.id, p."parentId", ${teamHasFeature(Prisma.sql`p.id`, featureId)} AS has_feature
      FROM "Team" p
      INNER JOIN TeamHierarchy c ON p.id = c."parentId"
      WHERE c.has_feature = 0
    )
    SELECT TOP 1 1 AS found FROM TeamHierarchy WHERE has_feature = 1
  `);
  return rows.length > 0;
}
