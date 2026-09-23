const express = require("express");
const cors = require("cors");
const path = require("path");
const helmet = require("helmet");

const rateLimit = require("express-rate-limit");

const { oxm_db } = require("./db.js");

const { save_log } = require("./save_logs.js");

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

// Security headers
app.use(helmet());

// Limit request body size
app.use(
  express.json({
    limit: "100kb",
  }),
);

app.use(
  express.urlencoded({
    extended: false,
    limit: "100kb",
  }),
);

app.use(cors());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.set("view engine", "ejs");
app.use(onRequest);

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // Minute
  limit: 5, // Requests
  standardHeaders: "draft-8",
  legacyHeaders: true,

  message: {
    error: "Too many requests. Please try again later.",
  },
  handler: (req, res) => {
    save_log("Rate limit hit. Server is busy. Please try again later.");
    res.status(500).json({
      success: false,
      message: "Rate limit hit. Server is busy. Please try again later.",
    });
  },
});
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
