import { getEnv } from "@/env";
import * as Sentry from "@sentry/nestjs";
import { nodeProfilingIntegration } from "@sentry/profiling-node";

if (process.env.SENTRY_DSN) {
  // Ensure to call this before requiring any other modules!
  Sentry.init({
    // Sentry 11 collects cookies, user fields and HTTP bodies by default; keep them off like sendDefaultPii: false did.
    dataCollection: { userInfo: false, cookies: false, httpBodies: [] },
    dsn: getEnv("SENTRY_DSN"),
    integrations: [nodeProfilingIntegration(), Sentry.prismaIntegration()],
    // Performance Monitoring
    tracesSampleRate: getEnv("SENTRY_TRACES_SAMPLE_RATE") ?? 1.0, //  Capture 100% of the transactions
    // Sentry 10+ replaced profilesSampleRate. "trace" keeps profiling tied to sampled transactions like before.
    profileSessionSampleRate: getEnv("SENTRY_PROFILES_SAMPLE_RATE") ?? 1.0,
    profileLifecycle: "trace",
  });
}
