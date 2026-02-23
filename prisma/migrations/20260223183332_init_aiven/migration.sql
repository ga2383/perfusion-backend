-- CreateEnum
CREATE TYPE "SystemState" AS ENUM ('IDLE', 'PRIMING', 'RUNNING', 'PAUSED', 'STOPPED', 'ERROR');

-- CreateEnum
CREATE TYPE "FlagLevel" AS ENUM ('OK', 'WARN', 'EMERGENCY', 'SENSOR_FAIL', 'DISCONNECTED', 'UNKNOWN');

-- CreateTable
CREATE TABLE "HopeRun" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "systemState" "SystemState" NOT NULL DEFAULT 'IDLE',
    "operatorName" TEXT NOT NULL,
    "liverMass_g" DOUBLE PRECISION NOT NULL,
    "pvPressureTarget_mmHg" DOUBLE PRECISION NOT NULL,
    "haPressureTarget_mmHg" DOUBLE PRECISION NOT NULL,
    "pvFlowTarget_mLmin" DOUBLE PRECISION NOT NULL,
    "haFlowTarget_mLmin" DOUBLE PRECISION NOT NULL,
    "tempTarget_C" DOUBLE PRECISION NOT NULL,
    "thresholds" JSONB NOT NULL,

    CONSTRAINT "HopeRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HopeReading" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "runId" INTEGER NOT NULL,
    "pvPressure_mmHg" DOUBLE PRECISION,
    "haPressure_mmHg" DOUBLE PRECISION,
    "pvFlow_mLmin" DOUBLE PRECISION,
    "haFlow_mLmin" DOUBLE PRECISION,
    "tempBath_C" DOUBLE PRECISION,
    "tempInflow_C" DOUBLE PRECISION,
    "tempPostHX_C" DOUBLE PRECISION,
    "tempOrganSurface_C" DOUBLE PRECISION,
    "o2GasConc_pct" DOUBLE PRECISION,
    "o2GasFlow_Lmin" DOUBLE PRECISION,
    "o2SensorTemp_C" DOUBLE PRECISION,
    "powerBus_V" DOUBLE PRECISION,
    "pressureWarning" BOOLEAN NOT NULL DEFAULT false,
    "pressureEmergency" BOOLEAN NOT NULL DEFAULT false,
    "tempWarning" BOOLEAN NOT NULL DEFAULT false,
    "tempEmergency" BOOLEAN NOT NULL DEFAULT false,
    "flowWarning" BOOLEAN NOT NULL DEFAULT false,
    "flowEmergency" BOOLEAN NOT NULL DEFAULT false,
    "sensorFlags" JSONB NOT NULL,
    "raw" JSONB NOT NULL,

    CONSTRAINT "HopeReading_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NmpRun" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "systemState" "SystemState" NOT NULL DEFAULT 'IDLE',
    "operatorName" TEXT NOT NULL,
    "liverMass_g" DOUBLE PRECISION NOT NULL,
    "mapTarget_mmHg" DOUBLE PRECISION NOT NULL,
    "flowTarget_mLmin" DOUBLE PRECISION NOT NULL,
    "tempTarget_C" DOUBLE PRECISION NOT NULL,
    "o2Target_pct" DOUBLE PRECISION NOT NULL,
    "thresholds" JSONB NOT NULL,

    CONSTRAINT "NmpRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NmpReading" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "runId" INTEGER NOT NULL,
    "arterialPressure_mmHg" DOUBLE PRECISION,
    "venousPressure_mmHg" DOUBLE PRECISION,
    "flow_mLmin" DOUBLE PRECISION,
    "tempReservoir_C" DOUBLE PRECISION,
    "tempInflow_C" DOUBLE PRECISION,
    "tempOutflow_C" DOUBLE PRECISION,
    "o2GasConc_pct" DOUBLE PRECISION,
    "o2GasFlow_Lmin" DOUBLE PRECISION,
    "lactate_mmolL" DOUBLE PRECISION,
    "ph" DOUBLE PRECISION,
    "glucose_mgdl" DOUBLE PRECISION,
    "powerBus_V" DOUBLE PRECISION,
    "pressureWarning" BOOLEAN NOT NULL DEFAULT false,
    "pressureEmergency" BOOLEAN NOT NULL DEFAULT false,
    "tempWarning" BOOLEAN NOT NULL DEFAULT false,
    "tempEmergency" BOOLEAN NOT NULL DEFAULT false,
    "flowWarning" BOOLEAN NOT NULL DEFAULT false,
    "flowEmergency" BOOLEAN NOT NULL DEFAULT false,
    "sensorFlags" JSONB NOT NULL,
    "raw" JSONB NOT NULL,

    CONSTRAINT "NmpReading_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AlarmEvent" (
    "id" SERIAL NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "level" "FlagLevel" NOT NULL,
    "message" TEXT NOT NULL,
    "raw" JSONB NOT NULL,
    "hopeRunId" INTEGER,
    "nmpRunId" INTEGER,

    CONSTRAINT "AlarmEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "HopeReading_runId_createdAt_idx" ON "HopeReading"("runId", "createdAt");

-- CreateIndex
CREATE INDEX "NmpReading_runId_createdAt_idx" ON "NmpReading"("runId", "createdAt");

-- CreateIndex
CREATE INDEX "AlarmEvent_createdAt_idx" ON "AlarmEvent"("createdAt");

-- AddForeignKey
ALTER TABLE "HopeReading" ADD CONSTRAINT "HopeReading_runId_fkey" FOREIGN KEY ("runId") REFERENCES "HopeRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NmpReading" ADD CONSTRAINT "NmpReading_runId_fkey" FOREIGN KEY ("runId") REFERENCES "NmpRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AlarmEvent" ADD CONSTRAINT "AlarmEvent_hopeRunId_fkey" FOREIGN KEY ("hopeRunId") REFERENCES "HopeRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AlarmEvent" ADD CONSTRAINT "AlarmEvent_nmpRunId_fkey" FOREIGN KEY ("nmpRunId") REFERENCES "NmpRun"("id") ON DELETE CASCADE ON UPDATE CASCADE;
