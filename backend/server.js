const express = require("express");
const cors = require("cors");
const path = require("path");

const rateLimit = require("express-rate-limit");

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  limit: 5, // 1000 requests
  standardHeaders: "draft-8",
  legacyHeaders: true,

  message: {
    error: "Too many requests. Please try again later.",
  },
  handler: (req, res) => {
    res.status(500).json({
      success: false,
      message: "Rate limit hit. Server is busy. Please try again later.",
    });
  },
});

const { oxm_db } = require("./db.js");

const initialize_database = async () => {
  // USERS
  await oxm_db.query(`
    CREATE TABLE IF NOT EXISTS users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

      profile_name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      user_password TEXT NOT NULL,

      joined TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

      verified BOOLEAN DEFAULT FALSE,
      is_admin BOOLEAN DEFAULT FALSE,
      is_superuser BOOLEAN DEFAULT FALSE
    );
  `);

  // TOKENS
  await oxm_db.query(`
    CREATE TABLE IF NOT EXISTS tokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        device_id UUID NOT NULL,

        created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
  `);
};
initialize_database();

require("dotenv").config();

const app = express();

const onRequest = (req, res, next) => {
  console.log(req.originalUrl);
  next();
};

app.use(express.static("public")); // To server Static HTML
app.use(express.raw({ type: "application/octet-stream", limit: "10mb" }));

app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.set("view engine", "ejs");
app.use(onRequest);

app.use(limiter);

app.set("trust proxy", 10);

const userRouter = require("./routes/users");
const tokensRouter = require("./routes/tokens");

app.use("/api/users", userRouter);
app.use("/api/tokens", tokensRouter);

console.log(`
============= xAPI ================
API Running... 
===================================
`);

app.listen(3000);
