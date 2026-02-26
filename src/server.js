import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import path from 'path';
import prisma from './db.js';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/perfusion', async (req, res) => {
  try {
    const metric = await prisma.perfusionMetric.findFirst({ orderBy: { timestamp: 'desc' } });
    if (metric) {
      return res.json({
        liverId: metric.liverId,
        timestamp: metric.timestamp instanceof Date ? metric.timestamp.toISOString() : metric.timestamp,
        metrics: {
          temperatureC: metric.temperatureC,
          flowMlMin: metric.flowMlMin,
          pressureMmHg: metric.pressureMmHg,
          oxygenationPct: metric.oxygenationPct ?? null
        }
      });
    }
  } catch (err) {
    console.error('GET /api/perfusion DB error', err);
  }
  // fallback
  res.json({
    liverId: 'LIV-001',
    timestamp: new Date().toISOString(),
    metrics: { temperatureC: 37.5, flowMlMin: 520, pressureMmHg: 62, oxygenationPct: 95 }
  });
});

app.get('/api/perfusion/history', async (req, res) => {
  try {
    const points = await prisma.perfusionMetric.findMany({ orderBy: { timestamp: 'desc' }, take: 12 });
    if (points && points.length) {
      const ordered = points.slice().reverse().map(p => ({
        timestamp: p.timestamp instanceof Date ? p.timestamp.toISOString() : p.timestamp,
        temperatureC: p.temperatureC,
        flowMlMin: p.flowMlMin,
        pressureMmHg: p.pressureMmHg
      }));
      return res.json({ liverId: points[0].liverId, points: ordered });
    }
  } catch (err) {
    console.error('GET /api/perfusion/history DB error', err);
  }
  // fallback simulated
  const now = Date.now();
  const points = [];
  for (let i = 11; i >= 0; i--) {
    const ts = new Date(now - i * 60 * 1000).toISOString();
    const temperatureC = 37.2 + Math.sin((now / 60000 + i) * 0.5) * 0.3;
    const flowMlMin = 500 + Math.round(Math.cos((now / 60000 + i) * 0.3) * 30);
    const pressureMmHg = 60 + Math.round(Math.sin((now / 60000 + i) * 0.4) * 4);
    points.push({ timestamp: ts, temperatureC: Number(temperatureC.toFixed(2)), flowMlMin, pressureMmHg });
  }
  res.json({ liverId: 'LIV-001', points });
});

// dev seed route
if (process.env.DEV_ALLOW_TEST_ROUTE === 'true') {
  app.post('/api/perfusion/seed', async (req, res) => {
    try {
      const now = new Date();
      const sample = {
        liverId: 'LIV-001',
        timestamp: now,
        temperatureC: 37.4,
        flowMlMin: 510,
        pressureMmHg: 61,
        oxygenationPct: 95
      };
      const created = await prisma.perfusionMetric.create({ data: sample });
      res.json({ success: true, created });
    } catch (err) {
      console.error('Seed error', err);
      res.status(500).json({ success: false, error: String(err) });
    }
  });
}

const PORT = process.env.PORT || 3001;
// Serve frontend build if it exists (optional)
import fs from 'fs';
import { fileURLToPath } from 'url';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const possibleFrontends = [
  path.join(__dirname, '..', 'frontend', 'build'),
  path.join(__dirname, '..', '..', 'frontend', 'build')
];

let served = false;
for (const dir of possibleFrontends) {
  const index = path.join(dir, 'index.html');
  if (fs.existsSync(index)) {
    app.use(express.static(dir));
    app.get('*', (_req, res) => res.sendFile(index));
    console.log('Serving frontend from', dir);
    served = true;
    break;
  }
}

app.listen(PORT, () => console.log(`Server listening on ${PORT} (frontend served=${served})`));
