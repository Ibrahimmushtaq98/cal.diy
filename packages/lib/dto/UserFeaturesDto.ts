import type { ZodObject } from "zod";
import { z } from "zod";

// Exact field types: zod 4 reads a ZodTypeAny field as unknown (zod 3 read it as any).
export const UserFeaturesDtoSchema: ZodObject<{
  userId: z.ZodNumber;
  featureId: z.ZodString;
  enabled: z.ZodBoolean;
  assignedBy: z.ZodString;
  updatedAt: z.ZodCoercedDate;
}> = z.object({
  userId: z.number(),
  featureId: z.string(),
  enabled: z.boolean(),
  assignedBy: z.string(),
  updatedAt: z.coerce.date(),
});

export type UserFeaturesDto = z.infer<typeof UserFeaturesDtoSchema>;
