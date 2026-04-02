// models/Medication.js
const mongoose = require("mongoose");

const medicationSchema = new mongoose.Schema({
  created_by: String,
  email: String,
  alarm_name: String,
  alarm_description: String,
  medication: [String],
  timers: [String]
});

module.exports = mongoose.model("Medication", medicationSchema);