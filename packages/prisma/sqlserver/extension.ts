// Makes the SQL Server Prisma client behave like the Postgres one the app is written against.
//
// The SQL Server schema (generate-schema.mjs) stores Json and list fields as NVARCHAR(MAX) text and enum
// fields as plain strings. This extension converts at the client boundary, using sqlserver/fields.json:
//   - writes: Json values and lists are JSON.stringify'd; Prisma.JsonNull/DbNull become NULL
//   - filters: Postgres-only options are rewritten (`mode: "insensitive"` is dropped because the
//     database collation is case-insensitive; list `has`/`hasSome`/`hasEvery`/`isEmpty` become text
//     matches on the JSON array)
//   - reads: Json and list columns are JSON.parse'd, through nested include/select results
// Filters with no SQL Server equivalent (Json `path`, `array_contains`, list `push`) throw a clear error
// so the call site can be ported, rather than silently returning wrong rows.
import { Prisma as PgPrisma, type PrismaClient } from "../generated/prisma/client";
import fieldMap from "./fields.json";

type ModelInfo = {
  table: string;
  json: string[];
  list: Record<string, string>;
  enum: Record<string, string>;
  columns: Record<string, string>;
  relations: Record<string, string>;
};
type FieldMap = { models: Record<string, ModelInfo> };

const models = (fieldMap as unknown as FieldMap).models;
const jsonFields = new Map(Object.entries(models).map(([m, i]) => [m, new Set(i.json)]));

type Obj = Record<string, unknown>;
const isObj = (v: unknown): v is Obj =>
  typeof v === "object" && v !== null && !Array.isArray(v) && !(v instanceof Date) && !isDecimal(v);
const isDecimal = (v: unknown) => typeof v === "object" && v !== null && v.constructor?.name === "Decimal";
const isNullSentinel = (v: unknown) =>
  v === PgPrisma.JsonNull || v === PgPrisma.DbNull || v === PgPrisma.AnyNull;

export class SqlServerUnsupportedError extends Error {
  constructor(what: string, model: string, field: string) {
    super(`SQL Server: ${what} on ${model}.${field} has no SQL Server equivalent; port this query.`);
    this.name = "SqlServerUnsupportedError";
  }
}

const isJson = (model: string, field: string) => jsonFields.get(model)?.has(field) ?? false;
const listType = (model: string, field: string) => models[model]?.list[field];
const relationOf = (model: string, field: string) => models[model]?.relations[field];

function toJsonText(value: unknown): unknown {
  if (value === undefined) return undefined;
  if (value === null || isNullSentinel(value)) return null;
  return JSON.stringify(value);
}

// ---------- writes ----------

function serializeData(model: string, data: unknown): unknown {
  if (Array.isArray(data)) return data.map((d) => serializeData(model, d));
  if (!isObj(data)) return data;
  const out: Obj = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === undefined) continue;
    if (isJson(model, key)) {
      out[key] = toJsonText(value);
    } else if (listType(model, key)) {
      if (Array.isArray(value)) out[key] = JSON.stringify(value);
      else if (isObj(value) && "set" in value) out[key] = JSON.stringify(value.set ?? []);
      else if (isObj(value) && "push" in value)
        throw new SqlServerUnsupportedError("list `push`", model, key);
      else out[key] = value;
    } else if (relationOf(model, key) && isObj(value)) {
      out[key] = serializeNestedWrite(relationOf(model, key) as string, value);
    } else {
      out[key] = value;
    }
  }
  return out;
}

const eachOrOne = (v: unknown, fn: (x: Obj) => Obj) =>
  Array.isArray(v) ? v.map((x) => fn(x as Obj)) : isObj(v) ? fn(v) : v;

function serializeNestedWrite(model: string, ops: Obj): Obj {
  const out: Obj = {};
  for (const [op, value] of Object.entries(ops)) {
    switch (op) {
      case "create":
        out[op] = serializeData(model, value);
        break;
      case "createMany":
        out[op] = isObj(value) ? { ...value, data: serializeData(model, value.data) } : value;
        break;
      case "connectOrCreate":
        out[op] = eachOrOne(value, (x) => ({
          ...x,
          where: serializeWhere(model, x.where),
          create: serializeData(model, x.create),
        }));
        break;
      case "upsert":
        out[op] = eachOrOne(value, (x) => ({
          ...x,
          ...(x.where !== undefined ? { where: serializeWhere(model, x.where) } : {}),
          create: serializeData(model, x.create),
          update: serializeData(model, x.update),
        }));
        break;
      case "update":
      case "updateMany":
        out[op] = eachOrOne(value, (x) => {
          const keys = Object.keys(x);
          const wrapped = "data" in x && keys.every((k) => k === "where" || k === "data");
          return wrapped
            ? {
                ...x,
                ...(x.where !== undefined ? { where: serializeWhere(model, x.where) } : {}),
                data: serializeData(model, x.data),
              }
            : (serializeData(model, x) as Obj);
        });
        break;
      case "connect":
      case "disconnect":
      case "delete":
      case "deleteMany":
      case "set":
        out[op] =
          typeof value === "boolean" ? value : eachOrOne(value, (x) => serializeWhere(model, x) as Obj);
        break;
      default:
        out[op] = value;
    }
  }
  return out;
}

// ---------- filters ----------

const textContains = (model: string, field: string, element: unknown) => {
  if (typeof element !== "string")
    throw new SqlServerUnsupportedError("list filter on non-text values", model, field);
  // The column holds a JSON array of strings, so the element appears as a quoted JSON string.
  return { contains: JSON.stringify(element) };
};

function serializeListFilter(model: string, field: string, filter: unknown, extra: Obj[]): unknown {
  if (!isObj(filter)) return filter === null ? null : JSON.stringify(filter);
  const out: Obj = {};
  for (const [op, v] of Object.entries(filter)) {
    if (op === "has") out.contains = textContains(model, field, v).contains;
    else if (op === "hasSome")
      extra.push({ OR: (v as unknown[]).map((e) => ({ [field]: textContains(model, field, e) })) });
    else if (op === "hasEvery")
      extra.push({ AND: (v as unknown[]).map((e) => ({ [field]: textContains(model, field, e) })) });
    else if (op === "isEmpty")
      extra.push(
        v
          ? { OR: [{ [field]: "[]" }, { [field]: null }] }
          : { NOT: { OR: [{ [field]: "[]" }, { [field]: null }] } }
      );
    else if (op === "equals") out.equals = v === null ? null : JSON.stringify(v);
    else throw new SqlServerUnsupportedError(`list filter \`${op}\``, model, field);
  }
  return Object.keys(out).length ? out : undefined;
}

function serializeJsonFilter(model: string, field: string, filter: unknown): unknown {
  if (!isObj(filter) || isNullSentinel(filter)) return toJsonText(filter);
  const out: Obj = {};
  for (const [op, v] of Object.entries(filter)) {
    if (op === "equals" || op === "not") out[op] = toJsonText(v);
    else if (op === "string_contains") out.contains = v;
    else if (op === "string_starts_with") out.startsWith = v;
    else if (op === "string_ends_with") out.endsWith = v;
    else if (op === "mode") continue;
    else throw new SqlServerUnsupportedError(`Json filter \`${op}\``, model, field);
  }
  return out;
}

function stripMode(filter: unknown): unknown {
  if (!isObj(filter) || !("mode" in filter)) return filter;
  const { mode: _mode, ...rest } = filter;
  if (isObj(rest.not)) rest.not = stripMode(rest.not);
  return rest;
}

function serializeWhere(model: string, where: unknown): unknown {
  if (Array.isArray(where)) return where.map((w) => serializeWhere(model, w));
  if (!isObj(where)) return where;
  const out: Obj = {};
  const extra: Obj[] = [];
  for (const [key, value] of Object.entries(where)) {
    if (value === undefined) continue;
    if (key === "AND" || key === "OR" || key === "NOT") {
      out[key] = serializeWhere(model, value);
    } else if (isJson(model, key)) {
      out[key] = serializeJsonFilter(model, key, value);
    } else if (listType(model, key)) {
      const v = serializeListFilter(model, key, value, extra);
      if (v !== undefined) out[key] = v;
    } else if (relationOf(model, key)) {
      const target = relationOf(model, key) as string;
      if (isObj(value)) {
        const rel: Obj = {};
        let isRelFilter = false;
        for (const [op, v] of Object.entries(value)) {
          if (["some", "every", "none", "is", "isNot"].includes(op)) {
            rel[op] = serializeWhere(target, v);
            isRelFilter = true;
          } else rel[op] = v;
        }
        out[key] = isRelFilter ? rel : serializeWhere(target, value);
      } else out[key] = value;
    } else if (isObj(value) && models[model]?.columns[key] !== undefined) {
      // compound unique inputs (e.g. userId_eventTypeId) are objects too; only scalar filters carry `mode`
      out[key] = stripMode(value);
    } else if (isObj(value) && !models[model]?.columns[key]) {
      // compound unique key: { a_b: { a, b } }
      out[key] = value;
    } else {
      out[key] = value;
    }
  }
  if (extra.length) out.AND = [...(Array.isArray(out.AND) ? out.AND : out.AND ? [out.AND] : []), ...extra];
  return out;
}

// select / include trees can carry relation filters too
function serializeSelection(model: string, selection: unknown): unknown {
  if (!isObj(selection)) return selection;
  const out: Obj = {};
  for (const [key, value] of Object.entries(selection)) {
    const target = relationOf(model, key);
    if (key === "_count" && isObj(value) && isObj(value.select)) {
      const sel: Obj = {};
      for (const [rel, v] of Object.entries(value.select)) {
        const t = relationOf(model, rel);
        sel[rel] = t && isObj(v) && v.where ? { ...v, where: serializeWhere(t, v.where) } : v;
      }
      out[key] = { ...value, select: sel };
    } else if (target && isObj(value)) {
      out[key] = serializeArgs(target, value);
    } else out[key] = value;
  }
  return out;
}

function serializeArgs(model: string, args: Obj): Obj {
  const out: Obj = { ...args };
  if (args.where !== undefined) out.where = serializeWhere(model, args.where);
  if (args.cursor !== undefined) out.cursor = serializeWhere(model, args.cursor);
  if (args.data !== undefined) out.data = serializeData(model, args.data);
  if (args.create !== undefined) out.create = serializeData(model, args.create);
  if (args.update !== undefined) out.update = serializeData(model, args.update);
  if (args.select !== undefined) out.select = serializeSelection(model, args.select);
  if (args.include !== undefined) out.include = serializeSelection(model, args.include);
  return out;
}

// ---------- reads ----------

function parseJsonText(text: unknown): unknown {
  if (typeof text !== "string") return text;
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

function deserialize(model: string, value: unknown): unknown {
  if (Array.isArray(value)) return value.map((v) => deserialize(model, v));
  if (!isObj(value)) return value;
  const info = models[model];
  if (!info) return value;
  for (const key of Object.keys(value)) {
    if (info.json.includes(key)) value[key] = parseJsonText(value[key]);
    else if (info.list[key]) value[key] = value[key] == null ? [] : parseJsonText(value[key]);
    else if (info.relations[key]) value[key] = deserialize(info.relations[key], value[key]);
  }
  return value;
}

const RECORD_RESULTS = new Set([
  "findUnique",
  "findUniqueOrThrow",
  "findFirst",
  "findFirstOrThrow",
  "findMany",
  "create",
  "createManyAndReturn",
  "update",
  "updateManyAndReturn",
  "upsert",
  "delete",
]);

export function sqlServerExtension(client: PrismaClient): PrismaClient {
  return client.$extends({
    name: "sqlserver-compat",
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }) {
          const nextArgs = isObj(args) ? serializeArgs(model, args) : args;
          if (isObj(nextArgs) && "skipDuplicates" in nextArgs) delete nextArgs.skipDuplicates;
          const result = await query(nextArgs);
          return RECORD_RESULTS.has(operation) ? deserialize(model, result) : result;
        },
      },
    },
  }) as unknown as PrismaClient;
}
