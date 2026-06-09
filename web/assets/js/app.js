/* ===========================================
   MAIN APPLICATION LOGIC
   =========================================== */

// Loading states
const LoadingStates = {
    IDLE: 'idle',
    LOADING: 'loading',
    ERROR: 'error',
    SUCCESS: 'success'
};

let currentLoadingState = LoadingStates.IDLE;
let apiKey = localStorage.getItem('apiKey') || '';

// Show/hide loading indicator
function setLoadingState(state, message = '') {
    currentLoadingState = state;
    const loader = document.getElementById('pageLoader');
    const errorMsg = document.getElementById('errorMessage');
    
    if (state === LoadingStates.LOADING) {
        if (loader) loader.style.display = 'flex';
        if (errorMsg) errorMsg.style.display = 'none';
    } else if (state === LoadingStates.ERROR) {
        if (loader) loader.style.display = 'none';
        if (errorMsg) {
            errorMsg.style.display = 'block';
            errorMsg.querySelector('.error-text').textContent = message;
        }
    } else {
        if (loader) loader.style.display = 'none';
        if (errorMsg) errorMsg.style.display = 'none';
    }
}

// Show toast notification
function showToast(message, type = 'info', duration = 3000) {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.classList.add('show');
    }, 10);
    
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

// Page Navigation with loading states
document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        
        const pageName = item.getAttribute('data-page');
        navigateToPage(pageName);
        
        // Update active nav item
        document.querySelectorAll('.nav-item').forEach(nav => nav.classList.remove('active'));
        item.classList.add('active');
    });
});

function navigateToPage(pageName) {
    // Hide all pages
    document.querySelectorAll('.page').forEach(page => {
        page.classList.remove('active');
    });
    
    // Show selected page
    const page = document.getElementById(pageName);
    if (page) {
        page.classList.add('active');
        
        // Load page-specific data
        loadPageData(pageName);
    }
    
    // Update page title
    const titles = {
        'dashboard': 'Dashboard',
        'logs': 'Log Analysis',
        'security': 'Security Threats',
        'traffic': 'Traffic Analysis',
        'reports': 'Reports',
        'settings': 'Settings'
    };
    
    document.getElementById('pageTitle').textContent = titles[pageName] || pageName;
}

// Load page-specific data
async function loadPageData(pageName) {
    setLoadingState(LoadingStates.LOADING);
    
    try {
        switch(pageName) {
            case 'dashboard':
                await loadDashboardPage();
                break;
            case 'logs':
                await loadLogsPage();
                break;
            case 'security':
                await loadSecurityPage();
                break;
            case 'traffic':
                await loadTrafficPage();
                break;
            case 'reports':
                await loadReportsPage();
                break;
            case 'settings':
                await loadSettingsPage();
                break;
        }
        setLoadingState(LoadingStates.SUCCESS);
    } catch (error) {
        console.error(`Error loading ${pageName}:`, error);
        setLoadingState(LoadingStates.ERROR, `Failed to load ${pageName}`);
    }
}

// Dashboard page data
async function loadDashboardPage() {
    const stats = await API.getDashboardStats();
    if (stats) {
        updateStatistics(stats);
    }
    
    const topIps = await API.getTopIps(4);
    if (topIps) {
        updateTopIpsTable(topIps);
    }
    
    const topUrls = await API.getTopUrls(4);
    if (topUrls) {
        updateTopUrlsTable(topUrls);
    }
}

// Logs page data
async function loadLogsPage() {
    const analysis = await API.getLogAnalysis({ limit: 50 });
    
    if (!analysis) {
        showToast('Failed to load log analysis', 'error');
        return;
    }
    
    // Get or create logs page container
    let logsPage = document.getElementById('logs');
    if (!logsPage.innerHTML.includes('logs-container')) {
        logsPage.innerHTML = createLogsPageHTML();
    }
    
    // Update logs data
    updateLogsAnalysis(analysis);
}

function createLogsPageHTML() {
    return `
        <div class="page-header">
            <h2>Log Analysis</h2>
            <button class="btn-primary" id="refreshLogsBtn">Refresh</button>
        </div>
        
        <div class="logs-container">
            <div class="data-container">
                <div class="data-header">
                    <h2>Top URLs</h2>
                    <span class="badge-info">Total: <span id="topUrlsCount">0</span></span>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>URL Path</th>
                            <th>Requests</th>
                            <th>Status Code</th>
                        </tr>
                    </thead>
                    <tbody id="logsUrlsTable">
                        <tr><td colspan="3" class="text-center">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
            
            <div class="data-container">
                <div class="data-header">
                    <h2>Status Code Distribution</h2>
                </div>
                <div id="statusCodeStats" style="padding: 20px;">
                    <p class="text-center">Loading...</p>
                </div>
            </div>
        </div>
    `;
}

function updateLogsAnalysis(analysis) {
    if (analysis.topUrls) {
        const table = document.getElementById('logsUrlsTable');
        table.innerHTML = Object.entries(analysis.topUrls).slice(0, 20).map(([url, count]) => `
            <tr>
                <td><code>${url}</code></td>
                <td><strong>${count}</strong></td>
                <td><span class="badge badge-success">200 OK</span></td>
            </tr>
        `).join('');
        document.getElementById('topUrlsCount').textContent = Object.keys(analysis.topUrls).length;
    }
    
    if (analysis.statusCodeDistribution) {
        const stats = analysis.statusCodeDistribution;
        const html = Object.entries(stats).map(([code, count]) => `
            <div style="margin: 10px 0; padding: 10px; background: var(--bg-secondary); border-radius: 6px;">
                <strong>${code}:</strong> ${count} requests
            </div>
        `).join('');
        document.getElementById('statusCodeStats').innerHTML = html || '<p>No data available</p>';
    }
    
    const btn = document.getElementById('refreshLogsBtn');
    if (btn) {
        btn.addEventListener('click', () => loadLogsPage());
    }
}

// Security page data
async function loadSecurityPage() {
    const threats = await API.getThreats();
    
    if (!threats) {
        showToast('Failed to load threats', 'error');
        return;
    }
    
    updateThreatsDisplay(threats);
}

function updateThreatsDisplay(threats) {
    const alertsSection = document.querySelector('.alerts-section');
    
    if (!threats || threats.length === 0) {
        alertsSection.innerHTML = '<p style="padding: 20px; text-align: center; color: var(--text-secondary);">No threats detected</p>';
        return;
    }
    
    alertsSection.innerHTML = threats.slice(0, 20).map(threat => {
        const severityClass = threat.severity === 'critical' ? 'alert-danger' : 'alert-warning';
        const iconClass = threat.severity === 'critical' ? 'fa-exclamation-triangle' : 'fa-shield-alt';
        
        return `
            <div class="alert-item ${severityClass}">
                <div class="alert-icon">
                    <i class="fas ${iconClass}"></i>
                </div>
                <div class="alert-content">
                    <h4>${threat.type.replace('_', ' ').toUpperCase()}</h4>
                    <p>IP: ${threat.ip} | Time: ${new Date(threat.timestamp).toLocaleTimeString()}</p>
                    <p>Request: <code>${threat.url}</code></p>
                    <span class="badge ${severityClass.includes('danger') ? 'badge-danger' : 'badge-warning'}">${threat.severity.toUpperCase()}</span>
                </div>
                <button class="btn-small" onclick="blockThreatIP('${threat.ip}')">Block IP</button>
            </div>
        `;
    }).join('');
}

// Traffic page data
async function loadTrafficPage() {
    const realtime = await API.getRealtimeLogs();
    
    if (!realtime) {
        showToast('Failed to load real-time data', 'error');
        return;
    }
    
    // Get or create traffic page container
    let trafficPage = document.getElementById('traffic');
    if (!trafficPage.innerHTML.includes('traffic-container')) {
        trafficPage.innerHTML = createTrafficPageHTML();
    }
    
    updateTrafficData(realtime);
}

function createTrafficPageHTML() {
    return `
        <div class="page-header">
            <h2>Traffic Analysis</h2>
            <button class="btn-primary" id="refreshTrafficBtn">Refresh</button>
        </div>
        
        <div class="traffic-container">
            <div class="data-container">
                <div class="data-header">
                    <h2>Real-time Logs</h2>
                    <span class="badge-info">Last 20 requests</span>
                </div>
                <div id="realtimeLogsDisplay" style="max-height: 500px; overflow-y: auto;">
                    <p class="text-center">Loading...</p>
                </div>
            </div>
        </div>
    `;
}

function updateTrafficData(realtimeLogs) {
    const display = document.getElementById('realtimeLogsDisplay');
    
    if (!realtimeLogs || realtimeLogs.length === 0) {
        display.innerHTML = '<p style="padding: 20px; text-align: center;">No logs available</p>';
        return;
    }
    
    display.innerHTML = realtimeLogs.slice(-20).map(log => `
        <div style="padding: 10px; border-bottom: 1px solid var(--border-color); font-family: monospace; font-size: 12px;">
            ${log}
        </div>
    `).join('');
    
    const btn = document.getElementById('refreshTrafficBtn');
    if (btn) {
        btn.addEventListener('click', () => loadTrafficPage());
    }
}

// Reports page data
async function loadReportsPage() {
    // Get or create reports page container
    let reportsPage = document.getElementById('reports');
    if (!reportsPage.innerHTML.includes('reports-container')) {
        reportsPage.innerHTML = createReportsPageHTML();
    }
    
    setupReportsHandlers();
}

function createReportsPageHTML() {
    return `
        <div class="page-header">
            <h2>Generate Reports</h2>
        </div>
        
        <div class="reports-container">
            <div class="data-container">
                <h3>Report Options</h3>
                
                <div class="form-group">
                    <label>Report Format</label>
                    <select id="reportFormat">
                        <option value="json">JSON</option>
                        <option value="csv">CSV</option>
                        <option value="html">HTML</option>
                    </select>
                </div>
                
                <button class="btn-primary" id="generateReportBtn">Generate Report</button>
            </div>
            
            <div class="data-container" id="reportResultContainer" style="display: none;">
                <h3>Report Generated</h3>
                <div id="reportResult"></div>
            </div>
        </div>
    `;
}

function setupReportsHandlers() {
    const generateBtn = document.getElementById('generateReportBtn');
    if (generateBtn) {
        generateBtn.addEventListener('click', async () => {
            const format = document.getElementById('reportFormat').value;
            setLoadingState(LoadingStates.LOADING, `Generating ${format.toUpperCase()} report...`);
            
            const report = await API.generateReport(format, apiKey);
            
            if (report) {
                showToast(`${format.toUpperCase()} report generated successfully`, 'success');
                const container = document.getElementById('reportResultContainer');
                container.style.display = 'block';
                
                if (format === 'json') {
                    document.getElementById('reportResult').innerHTML = `<pre>${JSON.stringify(report, null, 2)}</pre>`;
                } else {
                    document.getElementById('reportResult').innerHTML = `<p>Report generated. Download started.</p>`;
                }
            } else {
                showToast('Failed to generate report', 'error');
            }
            
            setLoadingState(LoadingStates.SUCCESS);
        });
    }
}

// Settings page data
async function loadSettingsPage() {
    const settings = await API.getSettings();
    
    if (!settings) {
        showToast('Failed to load settings', 'error');
        return;
    }
    
    updateSettingsForm(settings);
}

function updateSettingsForm(settings) {
    const form = document.querySelector('.settings-form');
    if (!form) return;
    
    form.innerHTML = `
        <div class="form-section">
            <h3>Log Configuration</h3>
            <div class="form-group">
                <label>Log File Path</label>
                <input type="text" id="logFilePath" value="${settings.logFilePath || ''}" placeholder="Enter log file path">
            </div>
            <div class="form-group">
                <label>Update Interval (seconds)</label>
                <input type="number" id="updateInterval" value="${settings.updateInterval || 30}" min="5" max="300">
            </div>
            <button class="btn-primary" id="saveSettingsBtn">Save Changes</button>
        </div>
        
        <div class="form-section">
            <h3>API Configuration</h3>
            <div class="form-group">
                <label>API Key</label>
                <input type="password" id="apiKeyInput" value="${apiKey}" placeholder="Enter API key for sensitive operations">
                <small>Required for: Block IP, Update Settings, Generate Reports</small>
            </div>
            <button class="btn-secondary" id="saveApiKeyBtn">Save API Key</button>
        </div>
    `;
    
    document.getElementById('saveSettingsBtn').addEventListener('click', async () => {
        const newSettings = {
            logFilePath: document.getElementById('logFilePath').value,
            updateInterval: parseInt(document.getElementById('updateInterval').value)
        };
        
        const result = await API.updateSettings(newSettings, apiKey);
        if (result && !result.error) {
            showToast('Settings updated successfully', 'success');
        } else {
            showToast('Failed to update settings', 'error');
        }
    });
    
    document.getElementById('saveApiKeyBtn').addEventListener('click', () => {
        const newKey = document.getElementById('apiKeyInput').value;
        localStorage.setItem('apiKey', newKey);
        apiKey = newKey;
        showToast('API key saved', 'success');
    });
}

// Block threat IP
async function blockThreatIP(ip) {
    if (!apiKey) {
        showToast('Please set API key in settings first', 'warning');
        navigateToPage('settings');
        return;
    }
    
    setLoadingState(LoadingStates.LOADING, `Blocking IP ${ip}...`);
    const result = await API.blockIp(ip, apiKey);
    
    if (result && !result.error) {
        showToast(`IP ${ip} blocked successfully`, 'success');
    } else {
        showToast(`Failed to block IP ${ip}`, 'error');
    }
    
    setLoadingState(LoadingStates.SUCCESS);
}

// Dark Mode Toggle
const themeToggle = document.getElementById('themeToggle');
if (themeToggle) {
    const isDarkMode = localStorage.getItem('darkMode') === 'true';
    if (isDarkMode) {
        document.body.classList.add('dark-mode');
        themeToggle.innerHTML = '<i class="fas fa-sun"></i>';
    }
    
    themeToggle.addEventListener('click', () => {
        document.body.classList.toggle('dark-mode');
        const isDark = document.body.classList.contains('dark-mode');
        localStorage.setItem('darkMode', isDark);
        themeToggle.innerHTML = isDark ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
    });
}

// Sidebar Toggle
const sidebarToggle = document.getElementById('sidebarToggle');
const menuToggle = document.getElementById('menuToggle');
const sidebar = document.querySelector('.sidebar');

if (sidebarToggle) {
    sidebarToggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
    });
}

if (menuToggle) {
    menuToggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
    });
}

// Close sidebar when clicking on a nav item on mobile
if (window.innerWidth <= 768) {
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', () => {
            sidebar.classList.remove('active');
        });
    });
}

// Auto-refresh data
let autoRefreshInterval;
let autoRefreshEnabled = true;

function startAutoRefresh() {
    autoRefreshInterval = setInterval(() => {
        if (autoRefreshEnabled) {
            const activePage = document.querySelector('.page.active');
            if (activePage) {
                const pageName = activePage.id;
                loadPageData(pageName);
            }
        }
    }, 30000); // Refresh every 30 seconds
}

function stopAutoRefresh() {
    if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
    }
}

startAutoRefresh();

// Responsive handling
window.addEventListener('resize', () => {
    if (window.innerWidth > 768 && sidebar.classList.contains('active')) {
        sidebar.classList.remove('active');
    }
});

console.log('App initialized successfully');
