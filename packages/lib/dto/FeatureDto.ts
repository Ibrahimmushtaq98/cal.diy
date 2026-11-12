import type { ZodArray, ZodObject } from "zod";
import { z } from "zod";

// Exact field types: zod 4 reads a ZodTypeAny field as unknown (zod 3 read it as any).
export const FeatureDtoSchema: ZodObject<{
  slug: z.ZodString;
  enabled: z.ZodBoolean;
  description: z.ZodNullable<z.ZodString>;
  type: z.ZodNullable<
    z.ZodEnum<{
      RELEASE: "RELEASE";
      EXPERIMENT: "EXPERIMENT";
      OPERATIONAL: "OPERATIONAL";
      PERMISSION: "PERMISSION";
      KILL_SWITCH: "KILL_SWITCH";
    }>
  >;
  stale: z.ZodNullable<z.ZodBoolean>;
  lastUsedAt: z.ZodNullable<z.ZodCoercedDate>;
  createdAt: z.ZodNullable<z.ZodCoercedDate>;
  updatedAt: z.ZodNullable<z.ZodCoercedDate>;
  updatedBy: z.ZodNullable<z.ZodNumber>;
}> = z.object({
  slug: z.string(),
  enabled: z.boolean(),
  description: z.string().nullable(),
  type: z.enum(["RELEASE", "EXPERIMENT", "OPERATIONAL", "PERMISSION", "KILL_SWITCH"]).nullable(),
  stale: z.boolean().nullable(),
  lastUsedAt: z.coerce.date().nullable(),
  createdAt: z.coerce.date().nullable(),
  updatedAt: z.coerce.date().nullable(),
  updatedBy: z.number().nullable(),
});

export type FeatureDto = z.infer<typeof FeatureDtoSchema>;

export const FeatureDtoArraySchema: ZodArray<typeof FeatureDtoSchema> = z.array(FeatureDtoSchema);
