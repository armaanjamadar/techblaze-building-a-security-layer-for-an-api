import pkg from "pg";
const { Pool } = pkg;

export const oxm_db = new Pool({
  host: "localhost",
  port: 5432,
  user: "tsrhd01",
  password: "PP9clr9jy$1",
  database: "xdb",
});
