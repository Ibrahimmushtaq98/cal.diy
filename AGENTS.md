# Cal.diy Development Guide for AI Agents

You are a senior Cal.diy engineer working in a Yarn/Turbo monorepo. You prioritize type safety, security, and small, reviewable diffs.

## Do

- Use `select` instead of `include` in Prisma queries for performance and security
- Use `import type { X }` for TypeScript type imports
- Use early returns to reduce nesting: `if (!booking) return null;`
- Use `ErrorWithCode` for errors in non-tRPC files (services, repositories, utilities); use `TRPCError` only in tRPC routers
- Use conventional commits: `feat:`, `fix:`, `refactor:`
- Create PRs in draft mode by default
- Run `yarn type-check:ci --force` before concluding CI failures are unrelated to your changes
- Import directly from source files, not barrel files (e.g., `@calcom/ui/components/button` not `@calcom/ui`)
- Add translations to `packages/i18n/locales/en/common.json` for all UI strings
- Use `date-fns` or native `Date` instead of Day.js when timezone awareness isn't needed
- Put permission checks in `page.tsx`, never in `layout.tsx`
- Use `ast-grep` for searching if available; otherwise use `rg` (ripgrep), then fall back to `grep`
- Use Biome for formatting and linting
- Only add code comments that explain **why**, not **what** — see [code comment guidelines](agents/rules/quality-code-comments.md)


## Don't

- Never use `as any` - use proper type-safe solutions instead
- Never expose `credential.key` field in API responses or queries
- Never commit secrets or API keys
- Never modify `*.generated.ts` files directly - they're created by app-store-cli
- Never put business logic in repositories - that belongs in Services
- Never use barrel imports from index.ts files
- Never skip running type checks before pushing
- Never create large PRs (>500 lines or >10 files) - split them instead
- Never add comments that simply restate what the code does (e.g., `// Get the user` above a `getUser()` call)

## PR Size Guidelines

Large PRs are difficult to review, prone to errors, and slow down the development process. Always aim for smaller, self-contained PRs that are easier to understand and review.

### Size Limits

- **Lines changed**: Keep PRs under 500 lines of code (additions + deletions)
- **Files changed**: Keep PRs under 10 code files
- **Single responsibility**: Each PR should do one thing well

**Note**: These limits apply to code files only. Non-code files like documentation (README.md, CHANGELOG.md), lock files (yarn.lock, package-lock.json), and auto-generated files are excluded from the count.

### How to Split Large Changes

When a task requires extensive changes, break it into multiple PRs:

1. **By layer**: Separate database/schema changes, backend logic, and frontend UI into different PRs
2. **By feature component**: Split a feature into its constituent parts (e.g., API endpoint PR, then UI PR, then integration PR)
3. **By refactor vs feature**: Do preparatory refactoring in a separate PR before adding new functionality
4. **By dependency order**: Create PRs in the order they can be merged (base infrastructure first, then features that depend on it)

### Examples of Good PR Splits

**Instead of one large "Add booking notifications" PR:**
- PR 1: Add notification preferences schema and migration
- PR 2: Add notification service and API endpoints
- PR 3: Add notification UI components
- PR 4: Integrate notifications into booking flow

**Instead of one large "Refactor calendar sync" PR:**
- PR 1: Extract calendar sync logic into dedicated service
- PR 2: Add new calendar provider abstraction
- PR 3: Migrate existing providers to new abstraction
- PR 4: Add new calendar provider support

### Benefits of Smaller PRs

- Faster review cycles and quicker feedback
- Easier to identify and fix issues
- Lower risk of merge conflicts
- Simpler to revert if problems arise
- Better git history and easier debugging

## Commands

See [agents/commands.md](agents/commands.md) for full reference. Key commands:

```bash
yarn type-check:ci --force  # Type check (always run before pushing)
yarn biome check --write .  # Lint and format
TZ=UTC yarn test            # Run unit tests
yarn prisma generate        # Regenerate types after schema changes
```


## Boundaries

### Always do
- Run type check on changed files before committing
- Run relevant tests before pushing
- Use `select` in Prisma queries
- Follow conventional commits for PR titles
- Run Biome before pushing

### Ask first
- Adding new dependencies
- Schema changes to `packages/prisma/schema.prisma`
- Changes affecting multiple packages
- Deleting files
- Running full build or E2E suites

### Never do
- Commit secrets, API keys, or `.env` files
- Expose `credential.key` in any query
- Use `as any` type casting
- Force push or rebase shared branches
- Modify generated files directly

## Project Structure

```
apps/web/                    # Main Next.js application
packages/prisma/             # Database schema (schema.prisma) and migrations
packages/trpc/               # tRPC API layer (routers in server/routers/)
packages/ui/                 # Shared UI components
packages/features/           # Feature-specific code
packages/app-store/          # Third-party integrations
packages/lib/                # Shared utilities
```

### Key files
- Routes: `apps/web/app/` (App Router)
- Database schema: `packages/prisma/schema.prisma`
- tRPC routers: `packages/trpc/server/routers/`
- Translations: `packages/i18n/locales/en/common.json`
- Workflow constants: `packages/features/ee/workflows/lib/constants.ts`

## Tech Stack

- **Framework**: Next.js 13+ (App Router in some areas)
- **Language**: TypeScript (strict)
- **Database**: PostgreSQL with Prisma ORM
- **API**: tRPC for type-safe APIs
- **Auth**: NextAuth.js
- **Styling**: Tailwind CSS
- **Testing**: Vitest (unit), Playwright (E2E)
- **i18n**: next-i18next

## Code Examples

### Good error handling

```typescript
// Good - Descriptive error with context
throw new Error(`Unable to create booking: User ${userId} has no available time slots for ${date}`);

// Bad - Generic error
throw new Error("Booking failed");
```

For which error class to use (`ErrorWithCode` vs `TRPCError`) and concrete examples, see [quality-error-handling](agents/rules/quality-error-handling.md).

### Good Prisma query

```typescript
// Good - Use select for performance and security
const booking = await prisma.booking.findFirst({
  select: {
    id: true,
    title: true,
    user: {
      select: {
        id: true,
        name: true,
        email: true,
      }
    }
  }
});

// Bad - Include fetches all fields including sensitive ones
const booking = await prisma.booking.findFirst({
  include: { user: true }
});
```

### Good imports

```typescript
// Good - Type imports and direct paths
import type { User } from "@prisma/client";
import { Button } from "@calcom/ui/components/button";

// Bad - Regular import for types, barrel imports
import { User } from "@prisma/client";
import { Button } from "@calcom/ui";
```

### API v2 Imports (apps/api/v2)

When importing from `@calcom/features` or `@calcom/trpc` into `apps/api/v2`, **do not import directly** because the API v2 app's `tsconfig.json` doesn't have path mappings for these modules, which causes "module not found" errors.

Instead, re-export from `packages/platform/libraries/index.ts` and import from `@calcom/platform-libraries`:

```typescript
// Step 1: In packages/platform/libraries/index.ts, add the export
export { ProfileRepository } from "@calcom/features/profile/repositories/ProfileRepository";

// Step 2: In apps/api/v2, import from platform-libraries
import { ProfileRepository } from "@calcom/platform-libraries";

// Bad - Direct import causes module not found error in apps/api/v2
import { ProfileRepository } from "@calcom/features/profile/repositories/ProfileRepository";
```

## PR Checklist

- [ ] Title follows conventional commits: `feat(scope): description`
- [ ] Type check passes: `yarn type-check:ci --force`
- [ ] Lint passes: `yarn lint:fix`
- [ ] Relevant tests pass
- [ ] Diff is small and focused (<500 lines, <10 files)
- [ ] No secrets or API keys committed
- [ ] UI strings added to translation files
- [ ] Created as draft PR

## When Stuck

- Ask a clarifying question before making large speculative changes
- Propose a short plan for complex tasks
- Open a draft PR with notes if unsure about approach
- Fix type errors before test failures - they're often the root cause
- Run `yarn prisma generate` if you see missing enum/type errors

## Spec-Driven Development (Opt-In)

For complex features, you can use spec-driven development when explicitly requested.

**To enable:** Tell the AI "use spec-driven development" or "follow the spec workflow"

See [SPEC-WORKFLOW.md](SPEC-WORKFLOW.md) for the full workflow documentation.

## Extended Documentation

For detailed information, see the `agents/` directory:

- **[agents/README.md](agents/README.md)** - Rules index and architecture overview
- **[agents/rules/](agents/rules/)** - Modular engineering rules
- **[agents/commands.md](agents/commands.md)** - Complete command reference
- **[agents/knowledge-base.md](agents/knowledge-base.md)** - Domain knowledge and business rules

## Labourly: run the local demo over ngrok

Labourly is evaluating Cal.diy for interview scheduling. This clone is set up so the web app is served publicly through a fixed ngrok address: **https://locust-epic-stud.ngrok-free.app**. Keep this setup unless someone asks to switch it back.

### What is already configured

- **`.env`** (not committed): the public URLs point at the tunnel instead of `localhost:3000`.
  ```
  NEXT_PUBLIC_WEBAPP_URL='https://locust-epic-stud.ngrok-free.app'
  NEXT_PUBLIC_WEBSITE_URL='https://locust-epic-stud.ngrok-free.app'
  NEXT_PUBLIC_EMBED_LIB_URL='https://locust-epic-stud.ngrok-free.app/embed/embed.js'
  ALLOWED_HOSTNAMES='"cal.local:3000","localhost:3000","locust-epic-stud.ngrok-free.app"'
  NEXTAUTH_URL='https://locust-epic-stud.ngrok-free.app'
  ```
  The localhost copy of the file is `.env.localhost.bak`.
- **`apps/web/next.config.ts`**: `allowedDevOrigins` lists the hostname from `NEXT_PUBLIC_WEBAPP_URL`. Next 16 rejects the dev HMR websocket (`/_next/hmr`) from any other origin. If it's rejected, booking pages load blank through the tunnel.

### Start it

1. Start Docker Desktop. Postgres (`prisma-postgres-1`, port 5450) and Mailhog (`emails-mailhog-1`: SMTP on 1025, inbox at http://localhost:8025) must be running. If they aren't:
   ```bash
   docker compose -f packages/prisma/docker-compose.yml up -d
   docker compose -f packages/emails/docker-compose.yml up -d
   ```
2. Start the web app from the repo root (the first page load takes a while to compile):
   ```bash
   yarn dev
   ```
3. In a second terminal, open the tunnel to port 3000:
   ```bash
   ngrok http --url=locust-epic-stud.ngrok-free.app 3000
   ```
4. Open https://locust-epic-stud.ngrok-free.app. ngrok's free plan shows a "Visit Site" warning page on the first visit from each browser. Sign in with a seeded user from `scripts/seed.ts` (for example `pro`, or `admin` for Settings → Admin).

Stop it with Ctrl-C in both terminals. The Docker containers can keep running.

### Gotchas

- `NEXT_PUBLIC_*` values are baked in when the app compiles. After changing the URL in `.env`, restart `yarn dev`.
- Sign-in only works on the URL in `NEXTAUTH_URL`. If you visit `localhost:3000` while `.env` points at ngrok, you get redirected or the login fails.
- Running `yarn dev` rewrites the `packages/app-store/*.generated.ts` files, so they show as modified in git. That's expected noise. Don't commit them.
- Each OAuth app (Google Calendar, Outlook/Teams, Zoom) needs callback URLs on the tunnel host, for example `https://locust-epic-stud.ngrok-free.app/api/integrations/office365video/callback`. These apps stay disabled and hidden from the App Store until their keys are set. Set them in `.env.appStore` and then run `yarn workspace @calcom/prisma seed-app-store`, or set them under Settings → Admin → Apps. Microsoft's keys are `MS_GRAPH_CLIENT_ID` / `MS_GRAPH_CLIENT_SECRET`. Google's is `GOOGLE_API_CREDENTIALS`.
- To test on `localhost:3000` without touching `.env`, start the web app directly with the URLs overridden (env vars you set win over `.env`):
  ```bash
  cd apps/web
  NEXT_PUBLIC_WEBAPP_URL=http://localhost:3000 NEXT_PUBLIC_WEBSITE_URL=http://localhost:3000 NEXTAUTH_URL=http://localhost:3000 yarn next dev --turbopack
  ```
- Next.js writes an `apps/web/AGENTS.md` on dev start. It's generated, so don't commit it.
- The browser console always shows "Service Worker registration failed" inside embedded browsers (for example the Claude Code browser pane). A normal browser registers it fine.

### Package versions held back on purpose

These were tried during the November 2026 updates (patch/minor first, then the major-version pass) and broke something. Don't bump them without fixing what's listed. When a package says "CommonJS", the reason is that API v2's jest run (and CI/Docker) is on Node 22, where jest can't `require()` an ESM-only package.

| Package | Held at | Why |
|---|---|---|
| `typescript` | 5.9.3 | 6.0 defaults `rootDir` to the tsconfig folder and stops loading `@types` on its own; API v2's nest build layout, the platform-libraries declaration build and the embed builds all rely on the old computed root. Needs an explicit `rootDir` per emitting package. 7.0 has no compiler API yet (ts-jest, Nest CLI, Prisma generators need it). |
| `next` | 16.4.3 | 16.4.5 puts dev pages into a full-reload loop (event types never load). 16.4.4 untested. |
| `@nestjs/*` | 11.x | Nest 12 is ESM-only (see CommonJS above) and its CLI wants TypeScript 6. |
| `@tanstack/react-table` | 8.21.3 | 9 moves to explicit feature registration and new generics: 244 type errors across the data tables. Needs its own pass with the bookings/users/OOO tables checked in a browser. |
| `otplib` | 12.0.1 | 13 is a rewrite of the TOTP API used by 2FA, email verification codes and account deletion. A mismatch locks people out; move it with tests that compare codes across versions. |
| `tslog` | 4.11.0 | 5 changes every logger call's signature. |
| `uuid` (API v2, prisma, platform-libraries) | 11.1.1 | 12+ is ESM-only (CommonJS). The rest of the repo is on 14. |
| `entities` (platform-libraries) | 4.5.0 | Same: the newer ones are ESM-only and get bundled into API v2's imports. |
| `sanitize-html` | 2.17.0 | 2.18 pulls in the ESM-only htmlparser2 12 (CommonJS). |
| `superjson` | 1.13.3 | 2.2.6 is ESM-only and 2.2.5's CJS build still loads the ESM-only copy-anything (CommonJS). |
| `@axiomhq/winston` 1.8, `http-proxy-middleware` 3.0.10 | as pinned | Next majors are ESM-only (CommonJS). |
| `meow` (app-store-cli) | 9.0.0 | 10+ needs `import.meta`; the CLI runs as CommonJS through ts-node. |
| `ink`, `ink-select-input`, `ink-text-input` | 3 / 4 / 4 | 4+ is ESM-only; ink 8 would also let app-store-cli leave React 18. Needs the CLI turned into an ES module. |
| `jotai` | 2.20.3 | `@daily-co/daily-react` (even its latest) needs jotai 2. |
| `stripe`, `@stripe/stripe-js`, `@stripe/react-stripe-js` | as pinned | New API-version pin and the old redirectToCheckout flow is gone; needs a Stripe test account to redo. |
| `@hubspot/api-client`, `@getalby/sdk`, `@getalby/lightning-tools`, `svix`, `@tryvital/vital-node`, `dub` | as pinned | API changes in app-store integrations that can't be checked without real accounts. |
| `jest-date-mock` | 1.0.10 | 1.0.11+ (published 19 May 2026) depends on a GitHub commit that doesn't exist; treat it as a bad publish. |
| `@base-ui/react` | 1.0.0 | 1.9 changes the `Input` props in `packages/coss-ui`. |
| `@formkit/auto-animate` | 1.0.0-beta.5 | Its stable 0.x line is older than the 1.0 beta in use; update tools pick it anyway. |
| `botid`, `@evyweb/ioctopus`, `@types/lodash`, `@types/glidejs__glide` | as pinned | Each newer version breaks type-checking in code that uses it. |
| `@microsoft/microsoft-graph-types-beta`, `@vercel/edge-config`, `next-axiom` | as pinned | No newer stable release to move to (preview-only or none eligible). |

### November 2026 major-version update: things to know

- **TypeScript resolution.** `nextjs.json`, `react-library.json` and the trpc tsconfigs use `moduleResolution: "bundler"` (lexical 0.53, react-timezone-select 4 and next-i18next 16 only publish types through `exports`). That also means deep imports must be listed in a package's `exports`. API v2 and the platform packages still compile with node resolution, so code they share can't import `exports`-only subpaths (see `packages/trpc/server/lib/ssrConfig.ts`).
- **zod 4.** A one-argument `z.ZodType<T>` annotation means input = `unknown` in zod 4; write `z.ZodType<T, T>` to get the zod 3 meaning. `packages/prisma/zod-utils.ts` sets zod's global `customError` so missing values still say "Required" (booking forms show these). Use `@calcom/lib/zodResolver`, not `@hookform/resolvers/zod` directly: it keeps `useForm<Values>` typing.
- **tRPC 11 stable.** The superjson transformer goes on each `httpLink`/`httpBatchLink`; `createTRPCNext` still needs it too for SSR.
- **Prisma 7.** Connection URLs and the seed command live in `packages/prisma/prisma.config.ts`, which also loads the root `.env`. `prismock` is patched (`.yarn/patches`) to import `@prisma/client/runtime/client`.
- **vitest 5 / Vite 8.** `vi.mock` must be top-level, `.resolves`/`.rejects` must be awaited, and Oxc only lowers our legacy decorators because `vitest.config.mts` sets `oxc.decorator.legacy`.
- **Sentry 11.** Every `Sentry.init` sets `dataCollection` to keep cookies, user fields and HTTP bodies off (Sentry 11 collects them by default).

### React 19

The web app, UI packages and atoms run on React 19.3 with `@types/react` 19.3 (November 2026). Things to know:

- `packages/types/react-global-jsx.d.ts` re-adds the global `JSX` namespace that React 19's types removed. react-select (and anything else still typed against global `JSX`) silently turns into `any` without it. Workspaces that type-check React code include it in their `tsconfig.json`.
- `packages/app-store-cli` stays on React 18: it uses ink 3, whose renderer only supports React 17/18 (ink 4+ is ESM-only; see the held table).
- React 19 calls function components with props only. Tests that assert a mocked component was called with `(props, {})` or `(props, expect.anything())` need to check `mock.lastCall?.[0]` instead.
- `@testing-library/react` 16 needs `@testing-library/dom` installed next to it; `renderHook` comes from `@testing-library/react` (the old `@testing-library/react-hooks` is gone).

### Switch back to localhost

```bash
cp .env.localhost.bak .env
```
Then restart `yarn dev` and leave ngrok off. The `allowedDevOrigins` line resolves to `localhost` by itself, so it can stay.
