const express = require("express");
const { MongoClient } = require("mongodb");

const app = express();
const port = 3000;

const mongoUri = process.env.MONGO_URI;

let dbStatus = "disconnected";

async function connectMongo() {
  try {
    const client = new MongoClient(mongoUri);
    await client.connect();
    dbStatus = "connected";
    console.log("MongoDB connected");
  } catch (err) {
    console.error("MongoDB connection failed:", err.message);
  }
}

connectMongo();

app.get("/", (req, res) => {
  res.json({
    service: "backend",
    mongo: dbStatus
  });
});

app.listen(port, () => {
  console.log(`Backend listening on port ${port}`);
});
