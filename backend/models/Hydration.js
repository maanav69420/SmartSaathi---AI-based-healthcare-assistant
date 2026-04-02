const mongoose = require("mongoose");

const hydrationSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true
  },

  // ✅ FIXED: Use Map instead of Object
  records: {
    type: Map,
    of: Number,
    default: {}
  },

  alerts: {
    type: [String],
    default: []
  }
});

module.exports = mongoose.model("Hydration", hydrationSchema);