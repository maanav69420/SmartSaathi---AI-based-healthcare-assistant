require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const app = express();

app.use(express.json());

// ✅ Connect DB
mongoose.connect("mongodb://127.0.0.1:27017/smartsarthi")
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.log(err));

// ✅ Routes
app.use("/user", require("./routes/user"));
app.use("/auth", require("./routes/auth")); // already exists
app.use("/medication", require("./routes/medication"));
app.use("/api/hydration", require("./routes/hydration"));
app.use("/chatbot", require("./routes/chatbot"));
app.listen(5000, () => console.log("Server running on port 5000"));