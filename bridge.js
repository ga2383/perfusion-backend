const { SerialPort, ReadlineParser } = require('serialport');
const { Client } = require('pg');

// 🛑 THE NUCLEAR OPTION: This forces Node.js to ignore the certificate error
process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

// 1. YOUR AIVEN DATABASE INFO
const dbConnectionString = "postgres://avnadmin:AVNS_QqC38bFQNZb8aCwdx5d@pg-19ca88eb-perfusion-backend.g.aivencloud.com:12009/defaultdb";

const pgClient = new Client({ 
    connectionString: dbConnectionString,
    ssl: true // Standard SSL enabled
});

async function start() {
    try {
        console.log("⏳ Attempting to connect to Aiven...");
        await pgClient.connect();
        console.log("✅ SUCCESS: Connected to Aiven Cloud Database!");
        
        await pgClient.query(`
            CREATE TABLE IF NOT EXISTS flow_data (
                id SERIAL PRIMARY KEY,
                f1 FLOAT, f2 FLOAT, f3 FLOAT, f4 FLOAT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        `);
        console.log("✅ Database Table is Ready.");
    } catch (err) {
        console.error("❌ Database Error:", err.message);
    }
}

// 2. SETUP USB CONNECTION
const port = new SerialPort({ path: 'COM3', baudRate: 115200 });
const parser = port.pipe(new ReadlineParser({ delimiter: '\r\n' }));

console.log("🔌 Waiting for data from STM32 on COM3...");

// 3. READ DATA AND SAVE TO CLOUD
parser.on('data', async (line) => {
    if (line.trim().startsWith('{')) { 
        try {
            const data = JSON.parse(line);
            console.log(`📥 Received: F1:${data.f1} F2:${data.f2} F3:${data.f3} F4:${data.f4}`);

            const query = 'INSERT INTO flow_data (f1, f2, f3, f4) VALUES ($1, $2, $3, $4)';
            const values = [data.f1, data.f2, data.f3, data.f4];
            
            await pgClient.query(query, values);
            console.log("☁️  Saved to Aiven Cloud!");
        } catch (e) {
            console.log("⚠️ Data Error:", e.message);
        }
    } else {
        console.log("Board Message:", line);
    }
});

start();