import { zodResolver as baseZodResolver } from "@hookform/resolvers/zod";
import type { FieldValues, Resolver } from "react-hook-form";
import type { z } from "zod";

/**
 * `zodResolver` typed the way our forms use it: `useForm<FormValues>({ resolver: zodResolver(schema) })`.
 *
 * @hookform/resolvers 5+ types the resolver with the schema's input *and* output types, so react-hook-form
 * infers a separate "transformed values" type and every `UseFormReturn<FormValues>` stops matching. Our forms
 * keep one values type, so this wrapper takes its type from the `useForm` call it's passed to.
 */
export function zodResolver<TFieldValues extends FieldValues = FieldValues>(
  schema: z.ZodType,
  schemaOptions?: Partial<z.core.ParseContext<z.core.$ZodIssue>>,
  resolverOptions?: { mode?: "async" | "sync"; raw?: false }
): Resolver<TFieldValues> {
  return baseZodResolver(
    schema as never,
    schemaOptions as never,
    resolverOptions as never
  ) as unknown as Resolver<TFieldValues>;
}
