import process from "node:process";
import { createKysely } from "./create";
import type { Booking, DB } from "./types";

export type { Booking, DB };
export { createKysely, tediousConfigFromUrl } from "./create";

const connectionString = process.env.DATABASE_URL ?? "postgresql://postgres:@localhost:5450/calendso";

const db = createKysely(connectionString);

export default db;
