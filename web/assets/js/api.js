/* ===========================================
   API INTEGRATION MODULE
   =========================================== */

const API = {
    // Use localhost with explicit port for development
    // For production, update this to your API server URL
    baseURL: window.location.hostname === 'localhost' 
        ? 'http://localhost:8765/api' 
        : '/api',
    
    // Get dashboard statistics
    async getDashboardStats() {
        try {
            const response = await axios.get(`${this.baseURL}/stats`);
            return response.data.data;
        } catch (error) {
            console.error('Error fetching dashboard stats:', error);
            return null;
        }
    },
    
    // Get log analysis data
    async getLogAnalysis(params = {}) {
        try {
            const response = await axios.get(`${this.baseURL}/logs/analysis`, { params });
            return response.data.data;
        } catch (error) {
            console.error('Error fetching log analysis:', error);
            return null;
        }
    },
    
    // Get top IPs
    async getTopIps(limit = 10) {
        try {
            const response = await axios.get(`${this.baseURL}/logs/top-ips`, { 
                params: { limit } 
            });
            return response.data.data;
        } catch (error) {
            console.error('Error fetching top IPs:', error);
            return null;
        }
    },
    
    // Get top URLs
    async getTopUrls(limit = 10) {
        try {
            const response = await axios.get(`${this.baseURL}/logs/top-urls`, { 
                params: { limit } 
            });
            return response.data.data;
        } catch (error) {
            console.error('Error fetching top URLs:', error);
            return null;
        }
    },
    
    // Get security threats
    async getThreats(params = {}) {
        try {
            const response = await axios.get(`${this.baseURL}/security/threats`, { params });
            return response.data.data;
        } catch (error) {
            console.error('Error fetching threats:', error);
            return null;
        }
    },
    
    // Get real-time logs
    async getRealtimeLogs() {
        try {
            const response = await axios.get(`${this.baseURL}/logs/realtime`);
            return response.data.data;
        } catch (error) {
            console.error('Error fetching realtime logs:', error);
            return null;
        }
    },
    
    // Block an IP
    async blockIp(ip, apiKey) {
        try {
            const response = await axios.post(`${this.baseURL}/security/block-ip`, 
                { ip },
                { headers: { 'X-API-Key': apiKey } }
            );
            return response.data;
        } catch (error) {
            console.error('Error blocking IP:', error);
            return null;
        }
    },
    
    // Generate report
    async generateReport(format = 'json', apiKey = null) {
        try {
            const config = {
                params: { format },
                responseType: format === 'csv' ? 'blob' : 'json'
            };
            
            if (apiKey) {
                config.headers = { 'X-API-Key': apiKey };
            }
            
            const response = await axios.get(`${this.baseURL}/reports/generate`, config);
            return response.data;
        } catch (error) {
            console.error('Error generating report:', error);
            return null;
        }
    },
    
    // Get settings
    async getSettings() {
        try {
            const response = await axios.get(`${this.baseURL}/settings`);
            return response.data.data;
        } catch (error) {
            console.error('Error fetching settings:', error);
            return null;
        }
    },
    
    // Update settings
    async updateSettings(settings, apiKey) {
        try {
            const response = await axios.put(
                `${this.baseURL}/settings`, 
                settings,
                { headers: { 'X-API-Key': apiKey } }
            );
            return response.data;
        } catch (error) {
            console.error('Error updating settings:', error);
            return null;
        }
    },
    
    // Health check
    async healthCheck() {
        try {
            const response = await axios.get(`${this.baseURL}/health`);
            return response.status === 200;
        } catch (error) {
            console.error('API health check failed:', error);
            return false;
        }
    }
};

// Axios configuration
axios.defaults.headers.common['Accept'] = 'application/json';
axios.defaults.headers.common['X-Requested-With'] = 'XMLHttpRequest';

// Response interceptor for error handling
axios.interceptors.response.use(
    response => response,
    error => {
        if (error.response && error.response.status === 401) {
            console.error('Unauthorized access');
            // Could redirect to login or show auth dialog
        }
        if (error.response && error.response.status === 404) {
            console.error('Resource not found');
        }
        return Promise.reject(error);
    }
);

// Initialize data loading
async function initializeDashboard() {
    try {
        // Check API health first
        const isHealthy = await API.healthCheck();
        if (!isHealthy) {
            console.warn('API server is not responding, using mock data');
            return;
        }
        
        // Load statistics
        const stats = await API.getDashboardStats();
        if (stats) {
            updateStatistics(stats);
        }
        
        // Load top IPs
        const topIps = await API.getTopIps(4);
        if (topIps) {
            updateTopIpsTable(topIps);
        }
        
        // Load top URLs
        const topUrls = await API.getTopUrls(4);
        if (topUrls) {
            updateTopUrlsTable(topUrls);
        }
    } catch (error) {
        console.error('Error initializing dashboard:', error);
    }
}

function updateStatistics(stats) {
    // Update stat cards
    const statElements = document.querySelectorAll('.stat-card');
    if (statElements[0] && stats.totalRequests) {
        statElements[0].querySelector('.stat-value').textContent = stats.totalRequests.toLocaleString();
    }
    if (statElements[1] && stats.errors) {
        statElements[1].querySelector('.stat-value').textContent = stats.errors.toLocaleString();
    }
    if (statElements[2] && stats.threats) {
        statElements[2].querySelector('.stat-value').textContent = stats.threats.toLocaleString();
    }
    if (statElements[3] && stats.bandwidth) {
        statElements[3].querySelector('.stat-value').textContent = stats.bandwidth;
    }
}

function updateTopIpsTable(ips) {
    const table = document.getElementById('topIpsTable');
    if (!table) return;
    
    table.innerHTML = ips.map(ip => `
        <tr>
            <td><span class="ip-badge">${ip.address}</span></td>
            <td><strong>${ip.requests}</strong></td>
            <td><span class="badge ${getBadgeClass(ip.status)}">${ip.status}</span></td>
            <td>${new Date(ip.lastSeen).toLocaleTimeString()}</td>
        </tr>
    `).join('');
}

function updateTopUrlsTable(urls) {
    const table = document.getElementById('topUrlsTable');
    if (!table) return;
    
    table.innerHTML = urls.map(url => `
        <tr>
            <td><code>${url.path}</code></td>
            <td><strong>${url.requests}</strong></td>
            <td>${url.avgResponseTime}ms</td>
            <td><span class="badge ${getBadgeClass(url.statusCode)}">${url.statusCode}</span></td>
        </tr>
    `).join('');
}

function getBadgeClass(status) {
    if (status === 'Clean' || status === '200 OK') return 'badge-success';
    if (status === 'Suspicious' || status === '403 Forbidden' || status === '404 Not Found') return 'badge-warning';
    if (status === 'Blocked') return 'badge-danger';
    return 'badge-info';
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializeDashboard);
