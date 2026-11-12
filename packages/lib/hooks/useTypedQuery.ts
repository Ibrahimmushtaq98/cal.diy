"use client";

import { usePathname, useRouter } from "next/navigation";
import { useCallback, useMemo, useEffect } from "react";
import { z } from "zod";

import { useRouterQuery } from "./useRouterQuery";

type OptionalKeys<T> = {
  [K in keyof T]-?: Record<string, unknown> extends Pick<T, K> ? K : never;
}[keyof T];

type FilteredKeys<T, U> = {
  [K in keyof T as T[K] extends U ? K : never]: T[K];
};

// Take array as a string and return zod array
export const queryNumberArray = z
  .string()
  .or(z.number())
  .or(z.array(z.number()))
  .transform((a) => {
    if (typeof a === "string") return a.split(",").map((a) => Number(a));
    if (Array.isArray(a)) return a;
    return [a];
  });

// Take array as a string and return zod  number array

// Take string and return return zod string array - comma separated
export const queryStringArray = z
  .preprocess((a) => z.string().parse(a).split(","), z.string().array())
  .or(z.string().array());

export function useTypedQuery<T extends z.ZodObject>(schema: T) {
  type Output = z.infer<typeof schema>;
  type FullOutput = Required<Output>;
  type OutputKeys = Required<keyof FullOutput>;
  type OutputOptionalKeys = OptionalKeys<Output>;
  type ArrayOutput = FilteredKeys<FullOutput, Array<unknown>>;
  type ArrayOutputKeys = keyof ArrayOutput;
  type ArrayItem<J extends ArrayOutputKeys> = ArrayOutput[J] extends Array<infer U> ? U : never;
  // zod 4 types a generic schema's output loosely; the query is always a flat record of strings.
  const toSearchParams = (query: Output) => new URLSearchParams(query as Record<string, string>);
  const router = useRouter();
  const unparsedQuery = useRouterQuery();
  const pathname = usePathname();
  const parsedQuerySchema = schema.safeParse(unparsedQuery);
  let parsedQuery: Output = useMemo(() => {
    return {} as Output;
  }, []);

  useEffect(() => {
    if (parsedQuerySchema.success && parsedQuerySchema.data) {
      Object.entries(parsedQuerySchema.data).forEach(([key, value]) => {
        if (key in unparsedQuery || !value) return;
        const search = toSearchParams(parsedQuery);
        search.set(String(key), String(value));
        router.replace(`${pathname}?${search.toString()}`);
      });
    }
  }, [parsedQuerySchema, schema, router, pathname, unparsedQuery, parsedQuery]);

  if (parsedQuerySchema.success) parsedQuery = parsedQuerySchema.data;
  else if (!parsedQuerySchema.success) console.error(parsedQuerySchema.error);

  // Set the query based on schema values
  const setQuery = useCallback(
    function setQuery<J extends OutputKeys>(key: J, value: Output[J]) {
      // Remove old value by key so we can merge new value
      const search = toSearchParams(parsedQuery);
      search.set(String(key), String(value));
      router.replace(`${pathname}?${search.toString()}`);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [parsedQuery, router]
  );

  // Delete a key from the query
  function removeByKey(key: OutputOptionalKeys) {
    const search = toSearchParams(parsedQuery);
    search.delete(String(key));
    router.replace(`${pathname}?${search.toString()}`);
  }

  // push item to existing key
  function pushItemToKey<J extends ArrayOutputKeys>(key: J, value: ArrayItem<J>) {
    const existingValue: unknown = parsedQuery[key as keyof Output];
    if (Array.isArray(existingValue)) {
      if (existingValue.includes(value)) return; // prevent adding the same value to the array
      setQuery(key as OutputKeys, [...existingValue, value] as Output[OutputKeys]);
    } else {
      setQuery(key as OutputKeys, [value] as Output[OutputKeys]);
    }
  }

  // Remove item by key and value
  function removeItemByKeyAndValue<J extends ArrayOutputKeys>(key: J, value: ArrayItem<J>) {
    const existingValue: unknown = parsedQuery[key as keyof Output];
    if (Array.isArray(existingValue) && existingValue.length > 1) {
      const newValue = existingValue.filter((item) => item !== value);
      setQuery(key as OutputKeys, newValue as Output[OutputKeys]);
    } else {
      removeByKey(key as unknown as OutputOptionalKeys);
    }
  }

  // Remove all query params from the URL
  function removeAllQueryParams() {
    if (pathname !== null) {
      router.replace(pathname);
    }
  }

  return {
    data: parsedQuery,
    setQuery,
    removeByKey,
    pushItemToKey,
    removeItemByKeyAndValue,
    removeAllQueryParams,
  };
}
