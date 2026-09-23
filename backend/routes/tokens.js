const express = require("express");
const router = express.Router();

const { oxm_db } = require("../db.js");
const { save_log } = require("../save_logs.js");

const fs = require("fs");

router.post("/", async (req, res) => {
  try {
    save_log("Creating user token");
    const { email, user_password, device_id } = req.body;

    // chekcing user with password
    const userResult = await oxm_db.query(
      `SELECT id FROM users 
       WHERE email = $1 AND user_password = $2`,
      [email, user_password],
    );

    if (userResult.rows.length === 0) {
      save_log("Invalid Email or Password");

      return res.status(200).json({
        success: false,
        message: "Invalid Email or Password",
      });
    }

    const userId = userResult.rows[0].id;

    // create token
    const tokenResult = await oxm_db.query(
      `INSERT INTO tokens (user_id, device_id)
       VALUES ($1, $2)
       RETURNING id, created`,
      [userId, device_id],
    );

    save_log("Token Auth Success");
    res.json({
      success: true,
      message: "Token Created",
      token: tokenResult.rows[0].id,
    });
  } catch (err) {
    save_log("Database Error");
    res.status(500).json({ success: false, message: "Database Error" });
  }
});

router.post("/delete", async (req, res) => {
  try {
    const { device_id, token_id } = req.body;

    const delete_query = await oxm_db.query(
      `DELETE FROM tokens WHERE id= $1 AND device_id= $2;`,
      [token_id, device_id],
    );
    save_log("Deleting user token");

    if (delete_query.rows.length === 1) {
      return res.status(500).json({ error: "Database error" });
    }
    res.status(200).send("Token Delete");
  } catch (err) {
    save_log("Database Error");
    return res.status(500).json({ error: "Database error" });
  }
});

module.exports = router;
