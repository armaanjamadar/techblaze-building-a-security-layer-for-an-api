const express = require("express");

const router = express.Router();

const { oxm_db } = require("../db.js");
const { save_log } = require("../save_logs.js");

/* FUNCTIONS 
- CREATE 
- READ 
*/

// 1. CREATE
router.post("/new", async (req, res, next) => {
  try {
    const { profile_name, email, user_password } = req.body;

    save_log("Request to create new user");

    // CHECK IF USER EXIST
    // ====================
    const user_result = await oxm_db.query(
      `SELECT id FROM users 
       WHERE email = $1;`,
      [email],
    );

    if (user_result.rows.length > 0) {
      save_log("Unable to create user. user already exist");
      return res.status(200).json({
        success: false,
        message: "User already exists. Try login in",
      });
    }

    // IF NOT CREATE ONE
    // ====================
    const { rows } = await oxm_db.query(
      `
      WITH ins AS (
        INSERT INTO users (profile_name, email, user_password)
        VALUES ($1, $2, $3)
        ON CONFLICT (email) DO NOTHING
        RETURNING *
      )
      SELECT * FROM ins
      UNION
      SELECT * FROM users WHERE email = $2
      LIMIT 1;
      `,
      [profile_name, email, user_password],
    );

    const user = rows[0];

    save_log("New User Created");
    res.status(200).json({
      success: true,
      message: "User Created",
    });
  } catch (err) {
    save_log("Database error while creating user");
    res.status(500).json({
      success: false,
      message: "Database error",
    });
  }
});

// 2. READ
router.route("/get_user").post(async (req, res) => {
  try {
    const { token } = req.body;

    save_log("Request for user data");

    const { rows } = await oxm_db.query(
      `
      SELECT u.*
      FROM tokens t
      JOIN users u ON u.id = t.user_id
      WHERE t.id = $1
      `,
      [token],
    );

    if (rows.length === 0) {
      save_log("Invalid Token Detected");
      return res.status(401).json({
        success: false,
        message: "Invalid token",
      });
    }

    const user = rows[0];

    // removing password
    delete user.user_password;

    save_log("User date request granted");
    res.json({
      success: true,
      message: "User data",
      user,
    });
  } catch (err) {
    save_log("Database error while porcessing user data required");
    res.status(500).json({
      success: false,
      message: "Database error while porcessing user data required",
    });
  }
});

module.exports = router;
