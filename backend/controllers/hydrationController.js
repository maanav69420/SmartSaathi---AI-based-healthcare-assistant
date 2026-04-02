// controllers/hydrationController.js

const HydrationRecord = require("../models/HydrationRecord");
const HydrationAlert = require("../models/HydrationAlert");

// ---------------- TARGET ----------------
const calculateTarget = (weight) => weight * 35;

// ---------------- TODAY RECORD ----------------
exports.getTodayRecord = async (req, res) => {
  const { email, weight } = req.body;

  const today = new Date().toISOString().split("T")[0];

  let record = await HydrationRecord.findOne({ email, date: today });

  if (!record) {
    record = await HydrationRecord.create({
      email,
      date: today,
      intake: 0
    });
  }

  const target = calculateTarget(weight);

  res.json({
    date: today,
    intake: record.intake,
    target
  });
};

// ---------------- ADD INTAKE ----------------
exports.addIntake = async (req, res) => {
  const { email, amount } = req.body;
  const today = new Date().toISOString().split("T")[0];

  let record = await HydrationRecord.findOne({ email, date: today });

  if (!record) {
    record = new HydrationRecord({
      email,
      date: today,
      intake: 0
    });
  }

  record.intake += amount;
  await record.save();

  res.json({
    message: "Intake added",
    intake: record.intake
  });
};

// ---------------- RESET ----------------
exports.resetIntake = async (req, res) => {
  const { email } = req.body;
  const today = new Date().toISOString().split("T")[0];

  await HydrationRecord.findOneAndUpdate(
    { email, date: today },
    { intake: 0 },
    { upsert: true }
  );

  res.json({ message: "Today's intake reset" });
};



// ---------------- AUTO ALERT SETUP ----------------
exports.autoSetupAlerts = async (req, res) => {
  const { email, wakeTime, sleepTime } = req.body;

  let alerts = [];

  let current = new Date(`1970-01-01T${wakeTime}:00`);
  current.setMinutes(current.getMinutes() + 30);

  let last = new Date(`1970-01-01T${sleepTime}:00`);
  last.setMinutes(last.getMinutes() - 30);

  while (current <= last) {
    alerts.push(current.toTimeString().slice(0, 5));
    current.setMinutes(current.getMinutes() + 150);
  }

  await HydrationAlert.findOneAndUpdate(
    { email },
    { alerts },
    { upsert: true }
  );

  res.json({
    message: "Alerts created",
    alerts
  });
};

// ---------------- GET ALERTS ----------------
exports.getAlerts = async (req, res) => {
  const { email } = req.query;

  const data = await HydrationAlert.findOne({ email });

  res.json({
    alerts: data?.alerts || []
  });
};

// ---------------- ADD ALERT ----------------
exports.addAlert = async (req, res) => {
  const { email, time } = req.body;

  let data = await HydrationAlert.findOne({ email });

  if (!data) {
    data = new HydrationAlert({ email, alerts: [] });
  }

  data.alerts.push(time);
  data.alerts.sort();

  await data.save();

  res.json({
    message: "Alert added",
    alerts: data.alerts
  });
};

// ---------------- DELETE ALERT ----------------
exports.deleteAlert = async (req, res) => {
  const { email, index } = req.body;

  let data = await HydrationAlert.findOne({ email });

  if (!data) return res.json({ alerts: [] });

  data.alerts.splice(index, 1);
  await data.save();

  res.json({
    message: "Alert removed",
    alerts: data.alerts
  });
};