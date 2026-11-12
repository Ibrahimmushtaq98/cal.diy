const quotePath = (file) => `"${file.replace(/"/g, '\\"')}"`;

export default {
  "(apps|packages|companion)/**/*.{js,ts,jsx,tsx}": (files) =>
    `biome lint --reporter summary --config-path=biome-staged.json ${files.map(quotePath).join(" ")}`,
  // Prisma 7 ignores the schema path in package.json, so run format from the prisma workspace.
  "packages/prisma/schema.prisma": () => "yarn workspace @calcom/prisma prisma format",
};
