const express = require("express");
const router = express.Router();
const User = require("../models/User");
const Medication = require("../models/Medication");

// ---------------- UPDATE ROUTINE ----------------
router.put("/update-routine", async (req, res) => {
  try {
    const { email, wakeTime, sleepTime } = req.body;

    await User.updateOne(
      { email: email },
      {
        $set: {
          routine: [wakeTime, sleepTime]
        }
      }
    );

    res.json({ message: "Routine updated" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update routine" });
  }
});

// ---------------- UPDATE WEIGHT ----------------
router.put("/update-weight", async (req, res) => {
  try {
    const { email, weight } = req.body;

    await User.updateOne(
      { email: email },
      {
        $set: { weight: weight }
      }
    );

    res.json({ message: "Weight updated" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update weight" });
  }
});

// ---------------- UPDATE AGE ----------------
router.put("/update-age", async (req, res) => {
  try {
    const { email, age } = req.body;

    await User.updateOne(
      { email: email },
      {
        $set: { age: age }
      }
    );

    res.json({ message: "Age updated" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update age" });
  }
});

// ---------------- UPDATE NAME + PASSWORD ----------------
router.put("/update-credentials", async (req, res) => {
  try {
    const { email, name, password } = req.body;

    const updateFields = {};

    if (name && name.trim() !== "") {
      updateFields.name = name;
    }

    if (password && password.trim() !== "") {
      updateFields.password = password;
    }

    // 🔥 Update USER collection
    await User.updateOne(
      { email: email },
      { $set: updateFields }
    );

    // 🔥 ALSO update medication collection (sync username)
    if (updateFields.name) {
      await Medication.updateMany(
        { email: email },
        { $set: { created_by: updateFields.name } }
      );
    }

    res.json({ message: "Profile updated everywhere" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update profile" });
  }
});

module.exports = router;