import WebSocket, { WebSocketServer } from 'ws';
import dotenv from 'dotenv';
import prisma from './db.js';

dotenv.config();

const PORT = parseInt(process.env.WS_PORT || '8080', 10);
const wss = new WebSocketServer({ port: PORT });
console.log(`WebSocket server listening on ws://0.0.0.0:${PORT}`);

function broadcast(obj) {
  const data = JSON.stringify(obj);
  for (const client of wss.clients) {
    if (client.readyState === WebSocket.OPEN) client.send(data);
  }
}

async function sendLatestPerfusion() {
  try {
    if (prisma && prisma.perfusionMetric) {
      const metric = await prisma.perfusionMetric.findFirst({ orderBy: { timestamp: 'desc' } });
      if (metric) {
        broadcast({ type: 'perfusion:latest', payload: {
          liverId: metric.liverId,
          timestamp: metric.timestamp instanceof Date ? metric.timestamp.toISOString() : metric.timestamp,
          metrics: {
            temperatureC: metric.temperatureC,
            flowMlMin: metric.flowMlMin,
            pressureMmHg: metric.pressureMmHg,
            oxygenationPct: metric.oxygenationPct ?? null
          }
        }});
        return;
      }
    }
  } catch (err) {
    console.error('WS: failed to load metric from DB', err);
  }

  const payload = {
    liverId: 'LIV-001',
    timestamp: new Date().toISOString(),
    metrics: {
      temperatureC: 37.5 + Math.random() * 0.4 - 0.2,
      flowMlMin: 500 + Math.round(Math.random() * 60 - 30),
      pressureMmHg: 60 + Math.round(Math.random() * 6 - 3),
      oxygenationPct: 94 + Math.round(Math.random() * 3)
    }
  };
  broadcast({ type: 'perfusion:latest', payload });
}

const INTERVAL_MS = parseInt(process.env.WS_BROADCAST_INTERVAL_MS || '5000', 10);
setInterval(sendLatestPerfusion, INTERVAL_MS);

wss.on('connection', (ws) => {
  console.log('WS client connected', { total: wss.clients.size });

  ws.on('message', (raw) => {
    let msg = raw.toString();
    try { msg = JSON.parse(msg); } catch (e) {}
    if (msg && msg.type === 'ping') {
      ws.send(JSON.stringify({ type: 'pong', ts: new Date().toISOString() }));
    }
  });

  sendLatestPerfusion();

  ws.on('close', () => {
    console.log('WS client disconnected', { total: wss.clients.size });
  });
});

export { wss };
