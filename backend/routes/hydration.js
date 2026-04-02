const express = require("express");
const router = express.Router();
const Hydration = require("../models/Hydration");

// ================= TODAY =================
router.post("/today", async (req, res) => {
  const { email, weight } = req.body;

  try {
    let data = await Hydration.findOne({ email });

    if (!data) {
      data = new Hydration({
        email,
        records: new Map(),
        alerts: []
      });
      await data.save();
    }

    const today = new Date().toISOString().split("T")[0];

    const intake = data.records.get(today) || 0;
    const target = weight * 35;

    res.json({ intake, target });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= ADD INTAKE =================
router.post("/add", async (req, res) => {
  const { email, amount } = req.body;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.status(404).json({ error: "User not found" });
    }

    const today = new Date().toISOString().split("T")[0];

    const current = data.records.get(today) || 0;
    data.records.set(today, current + amount);

    await data.save();

    res.json({
      message: "Intake added",
      intake: data.records.get(today)
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= RESET =================
router.post("/reset", async (req, res) => {
  const { email } = req.body;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.status(404).json({ error: "User not found" });
    }

    const today = new Date().toISOString().split("T")[0];

    data.records.set(today, 0);

    await data.save();

    res.json({ message: "Reset successful" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= GET ALERTS =================
router.get("/alerts", async (req, res) => {
  const { email } = req.query;

  try {
    const data = await Hydration.findOne({ email });

    res.json({ alerts: data?.alerts || [] });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= AUTO ALERTS =================
router.post("/alerts/auto", async (req, res) => {
  const { email, wakeTime, sleepTime } = req.body;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.status(404).json({ error: "User not found" });
    }

    const alerts = [];

    let start = new Date(`1970-01-01T${wakeTime}:00`);
    let end = new Date(`1970-01-01T${sleepTime}:00`);

    start.setMinutes(start.getMinutes() + 30);
    end.setMinutes(end.getMinutes() - 30);

    while (start <= end) {
      alerts.push(start.toTimeString().slice(0, 5));
      start.setMinutes(start.getMinutes() + 150);
    }

    data.alerts = alerts;
    await data.save();

    res.json({ message: "Auto alerts set" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= ADD ALERT =================
router.post("/alerts/add", async (req, res) => {
  const { email, time } = req.body;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.status(404).json({ error: "User not found" });
    }

    if (!data.alerts.includes(time)) {
      data.alerts.push(time);
      data.alerts.sort();
    }

    await data.save();

    res.json({ message: "Alert added" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= DELETE ALERT =================
router.post("/alerts/delete", async (req, res) => {
  const { email, index } = req.body;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.status(404).json({ error: "User not found" });
    }

    if (index >= 0 && index < data.alerts.length) {
      data.alerts.splice(index, 1);
    }

    await data.save();

    res.json({ message: "Alert deleted" });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ================= WEEKLY DATA =================
router.get("/weekly", async (req, res) => {
  const { email } = req.query;

  try {
    const data = await Hydration.findOne({ email });

    if (!data) {
      return res.json({ weekly: [0,0,0,0,0,0,0] });
    }

    const today = new Date();
    let result = [];

    for (let i = 6; i >= 0; i--) {
      let d = new Date();
      d.setDate(today.getDate() - i);

      let key = d.toISOString().split("T")[0];

      result.push(data.records.get(key) || 0);
    }

    res.json({ weekly: result });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;