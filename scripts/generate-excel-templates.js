const XLSX = require("xlsx");
const fs = require("fs");
const path = require("path");

function writeTemplate(filename, headers) {
  const ws = XLSX.utils.aoa_to_sheet([headers]);
  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, "template");

  const outDir = path.join(process.cwd(), "excel_templates");
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir);

  XLSX.writeFile(wb, path.join(outDir, filename));
  console.log("Wrote:", path.join(outDir, filename));
}

// HOPE columns (match your JSON keys)
const HOPE_HEADERS = [
  "timestamp",
  "runId",
  "pvPressure_mmHg",
  "haPressure_mmHg",
  "pvFlow_mLmin",
  "haFlow_mLmin",
  "tempBath_C",
  "tempInflow_C",
  "tempPostHX_C",
  "tempOrganSurface_C",
  "o2GasConc_pct",
  "o2GasFlow_Lmin",
  "o2SensorTemp_C",
  "powerBus_V",
  "pressureWarning",
  "pressureEmergency",
  "tempWarning",
  "tempEmergency",
  "flowWarning",
  "flowEmergency",
];

// NMP columns (match your JSON keys)
const NMP_HEADERS = [
  "timestamp",
  "runId",
  "arterialPressure_mmHg",
  "venousPressure_mmHg",
  "flow_mLmin",
  "tempReservoir_C",
  "tempInflow_C",
  "tempOutflow_C",
  "o2GasConc_pct",
  "o2GasFlow_Lmin",
  "lactate_mmolL",
  "ph",
  "glucose_mgdl",
  "powerBus_V",
  "pressureWarning",
  "pressureEmergency",
  "tempWarning",
  "tempEmergency",
  "flowWarning",
  "flowEmergency",
];

writeTemplate("HOPE_template.xlsx", HOPE_HEADERS);
writeTemplate("NMP_template.xlsx", NMP_HEADERS);



