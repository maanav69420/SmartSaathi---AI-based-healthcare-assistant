// routes/auth.js
const express = require("express");
const router = express.Router();
const User = require("../models/User");

// REGISTER
router.post("/register", async (req, res) => {
  try {
    const {
      name,
      email,
      age,
      routine,
      weight,
      password
    } = req.body;

    const newUser = new User({
      name,
      email,
      age,
      routine,
      weight,
      password
    });

    await newUser.save();

    res.json({ message: "User registered successfully" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Registration failed" });
  }
});

// LOGIN
router.post("/login", async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const user = await User.findOne({
      name: name,
      email: email,
      password: password
    });

    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    res.json({
      message: "Login successful",
      user: user
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;