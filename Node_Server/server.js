// app.js
import dotenv from 'dotenv';
import express from 'express';
import axios from 'axios';
import cors from 'cors';
import jwt from 'jsonwebtoken';
import fetch from 'node-fetch';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for Flutter to connect
app.use(cors());
app.use(express.json());

// API Key and Secret for JWT
const API_KEY = process.env.API_KEY || "fc73d100-c16c-47ee-a801-10ae91385cd4";
const SECRET = process.env.SECRET || "36b9a846ac442679f934cb5f7a1643de4e9cac04b1e677ccfeed92122871a1dd";

// Route to generate JWT token
app.get('/api/token', async (req, res) => {
  const options = {
    expiresIn: '120m',
    algorithm: 'HS256',
  };

  const payload = {
    apikey: API_KEY,
    permissions: ['allow_join'], // `ask_join` || `allow_mod`
  };

  try {
    const token = jwt.sign(payload, SECRET, options);
    res.json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Failed to generate token', details: err.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
