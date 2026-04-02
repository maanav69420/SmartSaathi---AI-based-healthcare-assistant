// models/User.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  name: String,
  email: String,
  age: Number,
  routine: [String],
  weight: Number,
  password: String
});

module.exports = mongoose.model("User", userSchema);