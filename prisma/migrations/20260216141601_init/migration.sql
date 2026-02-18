-- CreateTable
CREATE TABLE "PerfusionRun" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "runCode" TEXT NOT NULL,
    "startedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endedAt" DATETIME,
    "operatorName" TEXT,
    "organType" TEXT,
    "organMass_g" REAL,
    "mode" TEXT NOT NULL DEFAULT 'HOPE',
    "protocolName" TEXT,
    "notes" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- CreateTable
CREATE TABLE "Reading" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "runId" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "seq" INTEGER,
    "sourceTimestamp_ms" BIGINT,
    "mode" TEXT NOT NULL,
    "systemState" TEXT NOT NULL,
    "pvPressure_mmHg" REAL,
    "haPressure_mmHg" REAL,
    "pvFlow_mLmin" REAL,
    "haFlow_mLmin" REAL,
    "tempBath_C" REAL,
    "tempInflow_C" REAL,
    "tempPostHX_C" REAL,
    "tempOrganSurface_C" REAL,
    "o2GasConc_pct" REAL,
    "o2GasFlow_Lmin" REAL,
    "o2SensorTemp_C" REAL,
    "powerBus_V" REAL,
    "pressureWarning" BOOLEAN NOT NULL DEFAULT false,
    "pressureEmergency" BOOLEAN NOT NULL DEFAULT false,
    "tempWarning" BOOLEAN NOT NULL DEFAULT false,
    "oxygenWarning" BOOLEAN NOT NULL DEFAULT false,
    "safetyTriggered" BOOLEAN NOT NULL DEFAULT false,
    "pvPumpCmd_percent" REAL,
    "haPumpCmd_percent" REAL,
    "pumpEnabled" BOOLEAN,
    CONSTRAINT "Reading_runId_fkey" FOREIGN KEY ("runId") REFERENCES "PerfusionRun" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "AlarmEvent" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "runId" INTEGER,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "eventType" TEXT NOT NULL,
    "severity" TEXT NOT NULL DEFAULT 'WARN',
    "description" TEXT,
    "mode" TEXT,
    "systemState" TEXT,
    "acknowledged" BOOLEAN NOT NULL DEFAULT false,
    "acknowledgedAt" DATETIME,
    "resolved" BOOLEAN NOT NULL DEFAULT false,
    "resolvedAt" DATETIME,
    CONSTRAINT "AlarmEvent_runId_fkey" FOREIGN KEY ("runId") REFERENCES "PerfusionRun" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "SetpointSnapshot" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "runId" INTEGER NOT NULL,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "mode" TEXT NOT NULL,
    "liverMass_g" REAL,
    "tempBathTarget_C" REAL,
    "tempInflowTarget_C" REAL,
    "pvFlowTarget_mLmin" REAL,
    "haFlowTarget_mLmin" REAL,
    "pvPressureTarget_mmHg" REAL,
    "haPressureTarget_mmHg" REAL,
    "o2GasConcTarget_pct" REAL,
    "o2GasFlowTarget_Lmin" REAL,
    "warmRate_C_per_min" REAL,
    CONSTRAINT "SetpointSnapshot_runId_fkey" FOREIGN KEY ("runId") REFERENCES "PerfusionRun" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "PerfusionRun_runCode_key" ON "PerfusionRun"("runCode");

-- CreateIndex
CREATE INDEX "Reading_runId_idx" ON "Reading"("runId");

-- CreateIndex
CREATE INDEX "Reading_timestamp_idx" ON "Reading"("timestamp");

-- CreateIndex
CREATE UNIQUE INDEX "Reading_runId_timestamp_key" ON "Reading"("runId", "timestamp");

-- CreateIndex
CREATE INDEX "AlarmEvent_runId_idx" ON "AlarmEvent"("runId");

-- CreateIndex
CREATE INDEX "AlarmEvent_timestamp_idx" ON "AlarmEvent"("timestamp");

-- CreateIndex
CREATE INDEX "AlarmEvent_eventType_idx" ON "AlarmEvent"("eventType");

-- CreateIndex
CREATE INDEX "SetpointSnapshot_runId_idx" ON "SetpointSnapshot"("runId");

-- CreateIndex
CREATE INDEX "SetpointSnapshot_timestamp_idx" ON "SetpointSnapshot"("timestamp");
