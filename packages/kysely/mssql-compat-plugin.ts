// Lets the Postgres-flavoured Kysely queries in the app run on SQL Server (DATABASE_PROVIDER=sqlserver).
//
//   - .limit(n)            -> TOP (n), or OFFSET .. ROWS FETCH NEXT n ROWS ONLY when there is an offset
//   - ORDER BY in a subquery without TOP/OFFSET (not allowed in T-SQL) -> adds OFFSET 0 ROWS
//   - ilike / not ilike    -> like / not like (the database collation is case-insensitive)
//   - Postgres types in .cast() -> their T-SQL equivalents (json/jsonb/text -> nvarchar(max), ...)
import {
  type ColumnDataType,
  type DataTypeNode,
  FetchNode,
  type KyselyPlugin,
  OffsetNode,
  OperationNodeTransformer,
  OperatorNode,
  OrderByItemNode,
  OrderByNode,
  type PluginTransformQueryArgs,
  type PluginTransformResultArgs,
  type QueryResult,
  RawNode,
  type RootOperationNode,
  type SelectQueryNode,
  TopNode,
  type UnknownRow,
  ValueNode,
} from "kysely";

const CAST_TYPES: Record<string, string> = {
  json: "nvarchar(max)",
  jsonb: "nvarchar(max)",
  text: "nvarchar(max)",
  varchar: "nvarchar(max)",
  boolean: "bit",
  timestamp: "datetime2",
  timestamptz: "datetimeoffset",
  uuid: "uniqueidentifier",
  "double precision": "float",
  float8: "float",
  int4: "int",
  int8: "bigint",
};

function limitValue(node: SelectQueryNode): number {
  const limit = node.limit?.limit;
  if (limit && ValueNode.is(limit) && typeof limit.value === "number") return limit.value;
  throw new Error("SQL Server: .limit() needs a plain number");
}

class MssqlCompatTransformer extends OperationNodeTransformer {
  protected override transformSelectQuery(node: SelectQueryNode): SelectQueryNode {
    const n = super.transformSelectQuery(node);
    if (n.limit) {
      const rows = limitValue(n);
      if (!n.offset) return { ...n, limit: undefined, top: TopNode.create(rows) };
      return {
        ...n,
        limit: undefined,
        fetch: FetchNode.create(rows, "only"),
        // OFFSET/FETCH needs an ORDER BY
        orderBy: n.orderBy ?? OrderByNode.create([OrderByItemNode.create(RawNode.createWithSql("(select null)"))]),
      };
    }
    if (n.offset && !n.orderBy) {
      return { ...n, orderBy: OrderByNode.create([OrderByItemNode.create(RawNode.createWithSql("(select null)"))]) };
    }
    if (n.orderBy && !n.offset && !n.top && !n.fetch) {
      return { ...n, offset: OffsetNode.create(ValueNode.createImmediate(0)) };
    }
    return n;
  }

  protected override transformDataType(node: DataTypeNode): DataTypeNode {
    const mapped = CAST_TYPES[node.dataType];
    return mapped ? { ...node, dataType: mapped as ColumnDataType } : super.transformDataType(node);
  }

  protected override transformOperator(node: OperatorNode): OperatorNode {
    if (node.operator === "ilike") return OperatorNode.create("like");
    if (node.operator === "not ilike") return OperatorNode.create("not like");
    return super.transformOperator(node);
  }
}

export class MssqlCompatPlugin implements KyselyPlugin {
  private readonly transformer = new MssqlCompatTransformer();

  transformQuery(args: PluginTransformQueryArgs): RootOperationNode {
    return this.transformer.transformNode(args.node);
  }

  async transformResult(args: PluginTransformResultArgs): Promise<QueryResult<UnknownRow>> {
    return args.result;
  }
}
