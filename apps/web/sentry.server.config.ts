//biome-ignore-all lint/style/noProcessEnv: Server side
//biome-ignore-all lint/correctness/noProcessGlobal: Server side

// This file configures the initialization of Sentry on the server.
// The config you add here will be used whenever the server handles a request.
// https://docs.sentry.io/platforms/javascript/guides/nextjs/
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  // Sentry 11 collects cookies, user fields and HTTP bodies by default; keep them off like sendDefaultPii: false did.
  dataCollection: { userInfo: false, cookies: false, httpBodies: [] },
  debug: !!process.env.SENTRY_DEBUG,
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  sampleRate: parseFloat(process.env.SENTRY_SAMPLE_RATE ?? "1.0") || 1.0,
  tracesSampleRate: parseFloat(process.env.SENTRY_TRACES_SAMPLE_RATE ?? "0.0") || 0.0,
  integrations: [Sentry.prismaIntegration(), Sentry.httpIntegration()],
  beforeSend(event) {
    event.tags = {
      ...event.tags,
      errorSource: "server",
    };
    return event;
  },
});
