const express = require("express");
const router = express.Router();
const Medication = require("../models/Medication");

// ---------------- ADD MEDICATION ----------------
router.post("/add", async (req, res) => {
  try {
    const med = new Medication({
      email: req.body.email,                // ✅ IMPORTANT
      created_by: req.body.created_by,      // display name
      alarm_name: req.body.alarm_name,
      alarm_description: req.body.alarm_description,
      medication: req.body.medication,
      timers: req.body.timers
    });

    await med.save();

    res.json({ message: "Medication added" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to add medication" });
  }
});

// ---------------- GET MEDICATION ----------------
router.get("/:email", async (req, res) => {
  try {
    const meds = await Medication.find({
      email: req.params.email   // ✅ FIXED
    });

    res.json(meds);

  } catch (err) {
    res.status(500).json({ error: "Failed to fetch" });
  }
});

// ---------------- DELETE MEDICATION ----------------
router.delete("/delete", async (req, res) => {
  try {
    const { email, alarm_name } = req.body;

    await Medication.deleteOne({
      email: email,
      alarm_name: alarm_name
    });

    res.json({ message: "Deleted successfully" });

  } catch (err) {
    res.status(500).json({ error: "Delete failed" });
  }
});

module.exports = router;