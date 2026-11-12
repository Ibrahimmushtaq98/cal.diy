/**
 * Same shape as next-i18next's `SSRConfig` (what `serverSideTranslations` returns).
 *
 * Declared here instead of imported because next-i18next 16 only exposes it through package "exports"
 * (`next-i18next/pages`), which API v2 can't resolve: it compiles this package with node-style resolution.
 */
export type SSRConfig = {
  _nextI18Next?: {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    initialI18nStore: any;
    initialLocale: string;
    ns: string[];
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    userConfig: any;
  };
};
