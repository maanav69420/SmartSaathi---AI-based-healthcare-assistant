const express = require("express");
const router = express.Router();

const { extractMedicationData } = require("../services/openaiService");

router.post("/", async (req, res) => {
  try {
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: "Message is required" });
    }

    const data = await extractMedicationData(message);

    res.json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Chatbot failed" });
  }
});

module.exports = router;