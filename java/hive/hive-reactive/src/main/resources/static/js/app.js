// Hive Console Application

// DOM Elements
const sensorId = document.getElementById("sensorId");
const temperature = document.getElementById("temperature");
const latestTemp = document.getElementById("latestTemp");
const latestSensor = document.getElementById("latestSensor");
const minTemp = document.getElementById("minTemp");
const maxTemp = document.getElementById("maxTemp");
const avgTemp = document.getElementById("avgTemp");
const tempRange = document.getElementById("tempRange");
const sensorCount = document.getElementById("sensorCount");
const readingCount = document.getElementById("readingCount");
const statusOutput = document.getElementById("statusOutput");
const thermoFill = document.getElementById("thermoFill");
const historyBody = document.getElementById("historyBody");
const streamOutput = document.getElementById("streamOutput");
const streamStatus = document.getElementById("streamStatus");
const connectionStatus = document.getElementById("connectionStatus");
const sparkline = document.getElementById("sparkline");
const sparklineRange = document.getElementById("sparklineRange");
const toastContainer = document.getElementById("toastContainer");
const autoRefreshToggle = document.getElementById("autoRefreshToggle");
const darkModeToggle = document.getElementById("darkModeToggle");

const sensorPool = ["t-1", "t-2", "t-3", "t-4", "t-5", "t-6"];
const sensorColors = {
  "t-1": "#4a77b6",
  "t-2": "#3498db",
  "t-3": "#2ecc71",
  "t-4": "#9b59b6",
  "t-5": "#e74c3c",
  "t-6": "#1abc9c"
};

const state = {
  readings: [],
  autoRefresh: true,
  refreshInterval: null,
  uniqueSensors: new Set()
};

// Toast notifications
function showToast(message, type = "success") {
  const toast = document.createElement("div");
  toast.className = `toast ${type}`;
  toast.innerHTML = `
    <span class="toast-icon">${type === "success" ? "&#x2713;" : "&#x2717;"}</span>
    <span>${message}</span>
  `;
  toastContainer.appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}

// Dark mode
function toggleDarkMode() {
  const isDark = document.body.getAttribute("data-theme") === "dark";
  document.body.setAttribute("data-theme", isDark ? "" : "dark");
  darkModeToggle.textContent = isDark ? "\u263D" : "\u2600";
  localStorage.setItem("darkMode", !isDark);
}

// Initialize dark mode from localStorage
if (localStorage.getItem("darkMode") === "true") {
  document.body.setAttribute("data-theme", "dark");
  darkModeToggle.textContent = "\u2600";
}

darkModeToggle.addEventListener("click", toggleDarkMode);

// Auto-refresh toggle
autoRefreshToggle.addEventListener("click", () => {
  state.autoRefresh = !state.autoRefresh;
  autoRefreshToggle.classList.toggle("active", state.autoRefresh);
  if (state.autoRefresh) {
    startAutoRefresh();
  } else {
    clearInterval(state.refreshInterval);
  }
});

function startAutoRefresh() {
  if (state.refreshInterval) clearInterval(state.refreshInterval);
  state.refreshInterval = setInterval(() => {
    refreshStatus();
  }, 10000);
}

// Sensor chip selection
document.querySelectorAll(".sensor-chip").forEach(chip => {
  chip.addEventListener("click", () => {
    document.querySelectorAll(".sensor-chip").forEach(c => c.classList.remove("active"));
    chip.classList.add("active");
    sensorId.value = chip.dataset.sensor;
    refreshHistory();
    refreshLatest();
  });
});

// Utility functions
function nowIso() {
  return new Date().toISOString();
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function getTempClass(temp) {
  if (temp >= 30) return "temp-hot";
  if (temp >= 22) return "temp-warm";
  return "temp-cool";
}

// Update functions
function updateThermo(temp) {
  const height = clamp(((temp - 10) / 30) * 100, 5, 100);
  thermoFill.style.height = `${height}%`;
}

function updateKpis(reading) {
  if (!reading) return;
  const temp = reading.temperature.toFixed(1);
  latestTemp.innerHTML = `${temp}<span class="kpi-unit">°C</span>`;
  latestTemp.className = `kpi-value ${getTempClass(reading.temperature)}`;
  latestSensor.textContent = reading.sensorId;
  updateThermo(reading.temperature);
}

function updateStatus(status) {
  if (!status) return;
  minTemp.innerHTML = `${status.minTemperature.toFixed(1)}<span class="kpi-unit">°C</span>`;
  maxTemp.innerHTML = `${status.maxTemperature.toFixed(1)}<span class="kpi-unit">°C</span>`;
  statusOutput.textContent = JSON.stringify(status, null, 2);

  const range = status.maxTemperature - status.minTemperature;
  tempRange.textContent = range.toFixed(1) + "°";
}

function updateStats() {
  if (state.readings.length === 0) return;

  const temps = state.readings.map(r => r.temperature);
  const avg = temps.reduce((a, b) => a + b, 0) / temps.length;
  avgTemp.textContent = avg.toFixed(1) + "°";

  state.readings.forEach(r => state.uniqueSensors.add(r.sensorId));
  sensorCount.textContent = state.uniqueSensors.size;
  readingCount.textContent = `${state.readings.length} readings`;
}

function updateHistory(readings) {
  if (!readings || readings.length === 0) {
    historyBody.innerHTML = '<tr><td colspan="3" class="empty-state"><div class="empty-state-icon">&#x1F4ED;</div>No readings yet</td></tr>';
    return;
  }

  historyBody.innerHTML = "";
  readings.slice(0, 15).forEach((reading) => {
    const row = document.createElement("tr");
    const color = sensorColors[reading.sensorId] || "#4a77b6";
    row.innerHTML = `
      <td><span class="history-sensor"><span class="sensor-dot" style="background: ${color}"></span>${reading.sensorId}</span></td>
      <td class="history-temp">${reading.temperature.toFixed(1)}°C</td>
      <td class="history-time">${new Date(reading.timestamp).toLocaleTimeString()}</td>
    `;
    historyBody.appendChild(row);
  });
}

function updateSparkline() {
  if (state.readings.length === 0) {
    sparkline.textContent = "Waiting for data...";
    sparklineRange.textContent = "--";
    return;
  }
  const values = state.readings.slice(0, 24).map(r => r.temperature).reverse();
  const width = 260;
  const height = 50;
  const min = Math.min(...values);
  const max = Math.max(...values);
  const range = max - min || 1;

  sparklineRange.textContent = `${min.toFixed(1)}° - ${max.toFixed(1)}°`;

  const points = values.map((val, i) => {
    const x = (i / (values.length - 1 || 1)) * width;
    const y = height - ((val - min) / range) * (height - 10) - 5;
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  }).join(" ");

  const areaPoints = `0,${height} ${points} ${width},${height}`;

  sparkline.innerHTML = `
    <svg width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" fill="none">
      <defs>
        <linearGradient id="sparkGradient" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stop-color="#4a77b6" stop-opacity="0.3"/>
          <stop offset="100%" stop-color="#4a77b6" stop-opacity="0"/>
        </linearGradient>
      </defs>
      <polygon points="${areaPoints}" fill="url(#sparkGradient)" />
      <polyline points="${points}" stroke="#4a77b6" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round" />
      <circle cx="${(values.length - 1) / (values.length - 1 || 1) * width}" cy="${height - ((values[values.length - 1] - min) / range) * (height - 10) - 5}" r="4" fill="#4a77b6" />
    </svg>
  `;
}

// API functions
async function postReading(temp) {
  const submitBtn = document.getElementById("submitBtn");
  const originalContent = submitBtn.innerHTML;
  submitBtn.innerHTML = '<span class="btn-spinner"></span><span>Sending...</span>';
  submitBtn.disabled = true;

  const payload = {
    sensorId: sensorId.value.trim(),
    temperature: temp,
    timestamp: nowIso()
  };

  try {
    const response = await fetch("/api/readings", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (response.ok) {
      const result = await response.json();
      showToast(`Reading sent: ${temp.toFixed(1)}°C from ${payload.sensorId}`, "success");

      // Update weather display with the processing result
      const indoor = result.reading?.temperature;
      const outdoor = result.weather?.available ? result.weather.temperature : null;
      const delta = result.deltaFromOutdoor;
      updateWeatherDisplay(indoor, outdoor, delta);
    } else {
      const message = await response.text();
      showToast("Failed: " + message, "error");
    }
  } catch (err) {
    showToast("Network error: " + err.message, "error");
  } finally {
    submitBtn.innerHTML = originalContent;
    submitBtn.disabled = false;
  }
}

async function refreshStatus() {
  try {
    const response = await fetch("/api/status");
    if (response.ok) {
      updateStatus(await response.json());
    }
  } catch (err) {
    console.error("Failed to fetch status:", err);
  }
}

async function refreshHistory() {
  try {
    const id = sensorId.value.trim();
    const response = await fetch(`/api/readings/history?sensorId=${encodeURIComponent(id)}`);
    if (response.ok) {
      const data = await response.json();
      updateHistory(data);
    }
  } catch (err) {
    console.error("Failed to fetch history:", err);
  }
}

async function refreshLatest() {
  try {
    const id = sensorId.value.trim();
    const response = await fetch(`/api/readings/${encodeURIComponent(id)}`);
    if (response.ok) {
      updateKpis(await response.json());
    }
  } catch (err) {
    console.error("Failed to fetch latest:", err);
  }
}

function addReading(reading) {
  state.readings.unshift(reading);
  state.readings = state.readings.slice(0, 50);
  updateKpis(reading);
  updateSparkline();
  updateStats();
}

// Event listeners
document.getElementById("submitBtn").addEventListener("click", async () => {
  await postReading(Number(temperature.value));
});

document.getElementById("randomBtn").addEventListener("click", async () => {
  const temp = 18 + Math.random() * 12;
  const randomId = sensorPool[Math.floor(Math.random() * sensorPool.length)];
  sensorId.value = randomId;
  temperature.value = temp.toFixed(1);

  document.querySelectorAll(".sensor-chip").forEach(c => {
    c.classList.toggle("active", c.dataset.sensor === randomId);
  });

  await postReading(Number(temperature.value));
});

document.getElementById("refreshBtn").addEventListener("click", async () => {
  await Promise.all([refreshLatest(), refreshHistory(), refreshStatus()]);
  showToast("Data refreshed", "success");
});

document.getElementById("statusBtn").addEventListener("click", refreshStatus);

document.getElementById("clearStreamBtn").addEventListener("click", () => {
  streamOutput.innerHTML = "Stream cleared...";
});

// Keyboard shortcuts
document.addEventListener("keydown", (e) => {
  if (e.target.tagName === "INPUT") return;

  switch(e.key.toLowerCase()) {
    case "s":
      document.getElementById("submitBtn").click();
      break;
    case "r":
      document.getElementById("randomBtn").click();
      break;
    case "d":
      toggleDarkMode();
      break;
  }
});

// SSE Stream
let source;
function connectStream() {
  streamStatus.textContent = "Connecting...";
  connectionStatus.className = "status-indicator connecting";

  source = new EventSource("/api/stream");

  source.onopen = () => {
    streamStatus.textContent = "Connected";
    connectionStatus.className = "status-indicator";
  };

  // Listen for "temperature" named events (reactive uses named events)
  source.addEventListener("temperature", (event) => {
    handleStreamEvent(event);
  });

  // Also listen for unnamed events (vthreads compatibility)
  source.onmessage = (event) => {
    handleStreamEvent(event);
  };

  source.onerror = () => {
    streamStatus.textContent = "Reconnecting...";
    connectionStatus.className = "status-indicator error";
    source.close();
    setTimeout(connectStream, 2000);
  };
}

function handleStreamEvent(event) {
  let parsed;
  try {
    parsed = JSON.parse(event.data);
  } catch {
    parsed = null;
  }

  if (parsed) {
    addReading(parsed);
    const entry = document.createElement("div");
    entry.className = "stream-entry";
    entry.textContent = `[${new Date().toLocaleTimeString()}] ${parsed.sensorId}: ${parsed.temperature.toFixed(1)}°C`;
    streamOutput.insertBefore(entry, streamOutput.firstChild);

    // Keep only last 100 entries
    while (streamOutput.children.length > 100) {
      streamOutput.removeChild(streamOutput.lastChild);
    }
  } else if (event.data) {
    const entry = document.createElement("div");
    entry.className = "stream-entry";
    entry.textContent = event.data;
    streamOutput.insertBefore(entry, streamOutput.firstChild);
  }
}

// Alert Stream
const alertList = document.getElementById("alertList");
const alertCount = document.getElementById("alertCount");
const alerts = [];

function connectAlertStream() {
  const alertSource = new EventSource("/api/alerts/stream");

  alertSource.addEventListener("alert", (event) => {
    try {
      const alert = JSON.parse(event.data);
      addAlert(alert);
    } catch (e) {
      console.error("Failed to parse alert:", e);
    }
  });

  alertSource.onerror = () => {
    alertSource.close();
    setTimeout(connectAlertStream, 5000);
  };
}

function addAlert(alert) {
  alerts.unshift(alert);
  alerts.splice(20);
  alertCount.textContent = `${alerts.length} alerts`;

  const icons = { HIGH_TEMP: "&#x1F525;", LOW_TEMP: "&#x2744;", ABNORMAL_DELTA: "&#x26A0;" };
  const titles = { HIGH_TEMP: "High Temperature", LOW_TEMP: "Low Temperature", ABNORMAL_DELTA: "Abnormal Delta" };

  alertList.innerHTML = alerts.map(a => `
    <div class="alert-item ${a.alertType}">
      <span class="alert-icon">${icons[a.alertType] || "&#x26A0;"}</span>
      <div class="alert-content">
        <div class="alert-title">${titles[a.alertType] || a.alertType}</div>
        <div class="alert-detail">Sensor ${a.sensorId}: ${a.actualValue.toFixed(1)}°C (threshold: ${a.thresholdValue.toFixed(1)}°C)</div>
      </div>
      <span class="alert-time">${new Date(a.triggeredAt).toLocaleTimeString()}</span>
    </div>
  `).join("") || '<div class="empty-state"><div class="empty-state-icon">&#x2713;</div>No active alerts</div>';

  showToast(`Alert: ${titles[alert.alertType]} on ${alert.sensorId}`, "error");
}

async function refreshAlerts() {
  try {
    const response = await fetch("/api/alerts?limit=10");
    if (response.ok) {
      const data = await response.json();
      data.forEach(a => {
        if (!alerts.find(x => x.id === a.id)) alerts.push(a);
      });
      alerts.sort((a, b) => new Date(b.triggeredAt) - new Date(a.triggeredAt));
      alertCount.textContent = `${alerts.length} alerts`;
    }
  } catch (err) {
    console.error("Failed to fetch alerts:", err);
  }
}

function updateWeatherDisplay(indoor, outdoor, delta) {
  document.getElementById("indoorTemp").textContent = indoor ? indoor.toFixed(1) + "°C" : "--°C";
  document.getElementById("outdoorTemp").textContent = outdoor ? outdoor.toFixed(1) + "°C" : "--°C";

  const deltaElem = document.getElementById("tempDelta");
  const deltaValue = deltaElem.querySelector(".delta-value");

  if (delta !== null && delta !== undefined) {
    deltaValue.textContent = (delta >= 0 ? "+" : "") + delta.toFixed(1) + "°C";
    deltaElem.classList.remove("warning", "danger");
    if (Math.abs(delta) > 10) deltaElem.classList.add("danger");
    else if (Math.abs(delta) > 5) deltaElem.classList.add("warning");
  } else {
    deltaValue.textContent = "--°C";
  }

  document.getElementById("weatherStatus").textContent = outdoor ? "Live" : "N/A";
}

// Initialize
connectStream();
connectAlertStream();
refreshLatest();
refreshHistory();
refreshStatus();
refreshAlerts();
if (state.autoRefresh) startAutoRefresh();
