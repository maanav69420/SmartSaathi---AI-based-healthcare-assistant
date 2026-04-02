const OpenAI = require("openai");

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function extractMedicationData(message) {
  const response = await openai.chat.completions.create({
    model: "gpt-4o-mini",
    messages: [
      {
        role: "system",
        // 🔥 UPDATED SYSTEM PROMPT
content: `
You are SmartSaathi, a friendly healthcare assistant for elderly users.

You help with:
1. Medication reminders
2. Hydration tracking
3. General health queries

Respond in JSON ONLY:

{
  "type": "medication" | "hydration" | "general",
  "message": "Friendly human-like response",
  "data": {
    "alarm_name": "",
    "alarm_description": "",
    "medication": [],
    "timers": [],
    "action": ""
  }
}

Rules:
- Always include a warm, friendly message
- If hydration request:
  action can be: "add_intake", "show_status", "set_reminder"
- If medication request:
  fill medication + timers
- If general talk:
  type = "general"
- timers format: "HH:MM AM/PM"
- No extra text outside JSON
`,
      },
      {
        role: "user",
        content: message,
      },
    ],
  });

  // ✅ REPLACE THIS PART
const text = response.choices[0].message.content;

try {
  const clean = text.replace(/```json|```/g, "").trim();
  return JSON.parse(clean);
} catch (err) {
  throw new Error("Invalid JSON from AI");
}
}

module.exports = { extractMedicationData };