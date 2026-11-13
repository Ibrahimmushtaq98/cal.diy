import type { OnModuleDestroy } from "@nestjs/common";
import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import type { Kysely } from "kysely";

// Postgres or SQL Server, as DATABASE_PROVIDER selects. API v2 shares this client setup with the web app
// rather than copying it, so these two imports are allowed here.
// biome-ignore lint/style/noRestrictedImports: same Kysely client and DB types as the web app
import { createKysely } from "@calcom/kysely/create";
// biome-ignore lint/style/noRestrictedImports: same Kysely client and DB types as the web app
import type { DB } from "@calcom/kysely/types";

@Injectable()
export class KyselyWriteService implements OnModuleDestroy {
  private logger = new Logger("KyselyWriteService");

  public kysely: Kysely<DB>;

  constructor(readonly configService: ConfigService) {
    const dbUrl = configService.get("db.writeUrl", { infer: true });
    this.kysely = createKysely(dbUrl);
  }

  async onModuleDestroy() {
    try {
      await this.kysely.destroy();
    } catch (error) {
      this.logger.error(error);
    }
  }
}
