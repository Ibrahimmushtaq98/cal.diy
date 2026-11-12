import process from "node:process";
import { bookingIdempotencyKeyExtension } from "./extensions/booking-idempotency-key.ts";
import { disallowUndefinedDeleteUpdateManyExtension } from "./extensions/disallow-undefined-delete-update-many.ts";
import { excludeLockedUsersExtension } from "./extensions/exclude-locked-users.ts";
import { excludePendingPaymentsExtension } from "./extensions/exclude-pending-payment-teams.ts";
import type { PrismaClient as PgPrismaClient, Prisma } from "./generated/prisma/client.ts";
// The database driver and generated client for DATABASE_PROVIDER (postgresql by default, or sqlserver).
import {
  createAdapter,
  DATABASE_PROVIDER,
  PrismaClient,
  withProviderExtensions,
} from "./provider/selected.ts";
import { getConfiguredDatabaseProvider } from "./provider/types.ts";

type PrismaClient = PgPrismaClient;

// The client is chosen when `prisma generate` runs; a different DATABASE_PROVIDER at runtime would
// send this client's SQL to the wrong kind of database.
if (getConfiguredDatabaseProvider() !== DATABASE_PROVIDER) {
  throw new Error(
    `DATABASE_PROVIDER is "${process.env.DATABASE_PROVIDER ?? ""}" but the Prisma client was generated for ` +
      `"${DATABASE_PROVIDER}". Run \`yarn prisma generate\` (or yarn install) with the same DATABASE_PROVIDER.`
  );
}

const connectionString = process.env.DATABASE_URL || "";
const usePool = process.env.USE_POOL === "true" || process.env.USE_POOL === "1";
const { adapter } = createAdapter(
  connectionString,
  usePool ? { pool: { max: 5, idleTimeoutMillis: 300000 } } : undefined
);
const prismaOptions: Prisma.PrismaClientOptions = {
  adapter,
};

const globalForPrisma = global as unknown as {
  baseClient: PrismaClient;
};
const loggerLevel = parseInt(process.env.NEXT_PUBLIC_LOGGER_LEVEL ?? "", 10);

if (!isNaN(loggerLevel)) {
  switch (loggerLevel) {
    case 5:
    case 6:
      prismaOptions.log = ["error"];
      break;
    case 4:
      prismaOptions.log = ["warn", "error"];
      break;
    case 3:
      prismaOptions.log = ["info", "error", "warn"];
      break;
    default:
      // For values 0, 1, 2 (or anything else below 3)
      prismaOptions.log = ["query", "info", "error", "warn"];
      break;
  }
}
const baseClient = globalForPrisma.baseClient || withProviderExtensions(new PrismaClient(prismaOptions));

// Prisma 7 removed the `datasources` client option; a different database means a different driver adapter.
type CustomPrismaOptions = Pick<Prisma.PrismaClientOptions, "log" | "errorFormat" | "transactionOptions"> & {
  datasources?: { db?: { url?: string } };
};

export const customPrisma = (options?: CustomPrismaOptions) => {
  const { datasources, ...restOptions } = options ?? {};
  const customConnectionString = datasources?.db?.url;
  const finalOptions: Prisma.PrismaClientOptions = {
    ...prismaOptions,
    ...restOptions,
    adapter: customConnectionString ? createAdapter(customConnectionString).adapter : adapter,
  };

  return withProviderExtensions(new PrismaClient(finalOptions))
    .$extends(excludeLockedUsersExtension())
    .$extends(excludePendingPaymentsExtension())
    .$extends(bookingIdempotencyKeyExtension())
    .$extends(disallowUndefinedDeleteUpdateManyExtension()) as unknown as PrismaClient;
};

// FIXME: Due to some reason, there are types failing in certain places due to the $extends. Fix it and then enable it
// Specifically we get errors like `Type 'string | Date | null | undefined' is not assignable to type 'Exact<string | Date | null | undefined, string | Date | null | undefined>'`

// Explanation why we cast as PrismaClient. When we leave Prisma to its devices it tries to infer logic based on the extensions, but this is not a simple extends.
// this makes the PrismaClient export type-hint impossible and it also is a massive hit on Prisma type hinting performance.
export const prisma: PrismaClient = baseClient
  .$extends(excludeLockedUsersExtension())
  .$extends(excludePendingPaymentsExtension())
  .$extends(bookingIdempotencyKeyExtension())
  .$extends(disallowUndefinedDeleteUpdateManyExtension()) as unknown as PrismaClient;

// This prisma instance is meant to be used only for READ operations.
// If self hosting, feel free to leave INSIGHTS_DATABASE_URL as empty and `readonlyPrisma` will default to `prisma`.
export const readonlyPrisma = process.env.INSIGHTS_DATABASE_URL
  ? customPrisma({
      datasources: { db: { url: process.env.INSIGHTS_DATABASE_URL } },
    })
  : prisma;

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.baseClient = baseClient;
}

type OmitPrismaClient = Omit<
  PrismaClient,
  "$connect" | "$disconnect" | "$on" | "$transaction" | "$use" | "$extends"
>;

// we cant pass tx to functions as types miss match since we have a custom prisma client https://github.com/prisma/prisma/discussions/20924#discussioncomment-10077649
export type {
  OmitPrismaClient as PrismaTransaction,
  // we re-export the native PrismaClient type for backwards-compatibility.
  PrismaClient,
};

/**
 * @deprecated Use named export `prisma` instead
 */
export default prisma;
export * from "./selects/index.ts";
