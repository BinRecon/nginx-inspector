# 🛡️ Nginx Inspector

<div align="center">

[![GitHub](https://img.shields.io/badge/GitHub-shuvo--halder%2Fnginx--inspector-blue?logo=github&style=flat-square)](https://github.com/shuvo-halder/nginx-inspector)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.7+-blue?logo=python&style=flat-square)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-2.3+-green?logo=flask&style=flat-square)](https://flask.palletsprojects.com/)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-yellow?logo=javascript&style=flat-square)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

**Advanced Nginx Log Analyzer with Web Dashboard & REST API**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [API Documentation](#-api-documentation) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#-features)
- [System Requirements](#-system-requirements)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [API Documentation](#-api-documentation)
- [Web Dashboard](#-web-dashboard)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## Overview

**Nginx Inspector** is a comprehensive Nginx log analysis tool that provides real-time monitoring, security threat detection, and detailed traffic analytics through both a REST API and an interactive web dashboard.

Whether you're a system administrator managing production servers or a developer analyzing traffic patterns, Nginx Inspector gives you powerful insights into your Nginx logs with minimal setup.

### Key Highlights

✨ **Real-time Analysis** - Monitor Nginx logs as they're generated
🔒 **Security Detection** - Identify SQL injection, XSS, brute-force attacks, and suspicious activity
📊 **Rich Dashboard** - Beautiful, responsive web interface for data visualization
🚀 **REST API** - Full-featured API for programmatic access
🛡️ **Production Ready** - Error handling, validation, and security best practices
⚙️ **Configurable** - Flexible settings and customization options

---

## 🎯 Features

### Log Analysis
- ✅ **Top IP Analysis** - Identify your most active visitors
- ✅ **Top URLs Analysis** - See which endpoints receive the most traffic
- ✅ **HTTP Status Code Statistics** - Understand error rates and server health
- ✅ **User Agent Analysis** - Track browser and client types
- ✅ **404 Error Reports** - Find broken links and invalid requests
- ✅ **Bandwidth Usage** - Monitor data transfer patterns
- ✅ **Response Time Analysis** - Track performance metrics

### Security & Threat Detection
- 🔴 **SQL Injection Detection** - Identify SQL injection attack attempts
- 🔴 **XSS Detection** - Detect cross-site scripting patterns
- 🔴 **Directory Traversal Detection** - Catch path traversal attacks
- 🔴 **Command Injection Detection** - Identify command execution attempts
- 🔴 **Scanner Tool Detection** - Recognize security scanning tools (Nikto, SQLMap, Nmap)
- 🔴 **Brute-Force Detection** - Identify brute-force login attempts
- 🔴 **Suspicious IP Detection** - Flag IPs with abnormal behavior
- 🟡 **IP Blocking** - Block suspicious IPs via API

### Dashboard Features
- 📈 **Real-time Statistics** - Live request, error, and threat counts
- 📊 **Interactive Charts** - Visualize trends over time
- 🌓 **Dark/Light Mode** - Choose your preferred theme
- 📱 **Responsive Design** - Works on desktop, tablet, and mobile
- 🔄 **Auto-refresh** - Automatic data updates every 30 seconds
- ⚡ **Fast Loading** - Optimized performance with caching

### Report Generation
- 📄 **JSON Reports** - Machine-readable format for automation
- 📊 **CSV Reports** - Excel-compatible format for data analysis
- 🌐 **HTML Reports** - Pretty-printed reports for sharing
- 🎯 **Custom Filters** - Generate reports for specific time periods

---

## 💻 System Requirements

### Minimum Requirements
- **OS**: Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)
- **Python**: 3.7 or higher
- **Nginx**: Any recent version with access logs enabled
- **RAM**: 512 MB
- **Disk Space**: 100 MB for installation + space for log files

### Recommended
- **OS**: Ubuntu 20.04+ / CentOS 8+
- **Python**: 3.9+
- **RAM**: 2 GB+
- **CPU**: 2+ cores for production use

### Browser Support
- Chrome/Chromium 80+
- Firefox 75+
- Safari 13+
- Edge 80+

---

## 📦 Installation

### Prerequisites
```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Python and pip (if not installed)
sudo apt-get install -y python3 python3-pip python3-venv

# Install Nginx (if not installed)
sudo apt-get install -y nginx
```

### Step 1: Clone the Repository
```bash
# Clone from GitHub
git clone https://github.com/shuvo-halder/nginx-inspector.git

# Navigate to project directory
cd nginx-inspector
```

### Step 2: Run Installation Script
```bash
# Make install script executable
chmod +x install.sh

# Run installation with sudo
sudo bash install.sh
```

The installer will:
- ✅ Install Python dependencies (Flask, CORS support)
- ✅ Create virtual environment
- ✅ Copy files to `/usr/local/nginx-inspector/`
- ✅ Install systemd service
- ✅ Set up command-line interface

### Step 3: Verify Installation
```bash
# Check if nginx-inspector command is available
nginx-inspector --version

# Check service status
sudo systemctl status nginx-inspector

# View service logs
sudo journalctl -u nginx-inspector -f
```

### Manual Installation (Alternative)
```bash
# Create installation directory
mkdir -p ~/nginx-inspector
cd ~/nginx-inspector

# Copy repository files
cp -r ~/downloads/nginx-inspector/* .

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run API server
python api/api-server.py
```

---

## 🚀 Quick Start

### Start the API Server
```bash
# Using systemd service
sudo systemctl start nginx-inspector
sudo systemctl enable nginx-inspector  # Enable on boot

# Or manually
python api/api-server.py
```

### Access the Web Dashboard
Open your browser and navigate to:
```
http://localhost:8080/web/
```

Or if running on a remote server:
```
http://your-server-ip:8080/web/
```

### Test the API
```bash
# Health check
curl http://localhost:8765/api/health

# Get dashboard statistics
curl http://localhost:8765/api/stats

# Get top IPs
curl http://localhost:8765/api/logs/top-ips?limit=10

# Get security threats
curl http://localhost:8765/api/security/threats
```

---

## 💡 Usage

### Web Dashboard

#### 1. Dashboard Page
- **Real-time Statistics**: View total requests, errors, alerts, and bandwidth
- **Request Trends**: Charts showing request patterns over time
- **Status Code Distribution**: Pie chart of HTTP status codes
- **Top IPs**: Table of most active IP addresses
- **Top URLs**: Table of most requested endpoints

**How to use:**
1. Navigate to the Dashboard tab (default on load)
2. Statistics auto-update every 30 seconds
3. Hover over charts for detailed tooltips
4. Click "View All" to see complete lists

#### 2. Log Analysis Page
- **Detailed URL Analysis**: All URLs with request counts
- **Status Code Breakdown**: Distribution of HTTP responses
- **Request Patterns**: Time-based request analysis

**How to use:**
1. Click "Log Analysis" in the sidebar
2. Click "Refresh" to update data
3. View status code statistics
4. Export data using report generation

#### 3. Security Threats Page
- **Active Threats**: Real-time threat alerts
- **Threat Types**: SQL injection, XSS, brute-force, etc.
- **Severity Levels**: Critical, High, Medium, Info
- **Quick Actions**: Block IP, Rate limit, Investigate

**How to use:**
1. Click "Security Threats" in the sidebar
2. Review detected threats
3. Click "Block IP" to add suspicious IPs to blocklist
4. Threats sorted by severity (Critical first)

#### 4. Traffic Analysis Page
- **Real-time Logs**: Last 20 Nginx access log entries
- **Live Updates**: Refresh to see latest entries
- **Raw Log View**: View complete log lines

**How to use:**
1. Click "Traffic Analysis" in the sidebar
2. Click "Refresh" to update
3. Scroll through recent log entries
4. Use browser search (Ctrl+F) to find specific entries

#### 5. Reports Page
- **Report Generation**: Create custom reports
- **Multiple Formats**: JSON, CSV, HTML
- **Time Filtering**: Generate reports for specific periods

**How to use:**
1. Click "Reports" in the sidebar
2. Select report format (JSON, CSV, or HTML)
3. Click "Generate Report"
4. View or download the generated report

#### 6. Settings Page
- **Log File Configuration**: Set Nginx log file path
- **Update Interval**: Adjust refresh frequency
- **API Key Management**: Set API key for sensitive operations

**How to use:**
1. Click "Settings" in the sidebar
2. Update log file path if needed
3. Set update interval (5-300 seconds)
4. Enter API key (required for IP blocking)
5. Click "Save Changes"

### API Usage

#### Authentication
Sensitive endpoints require an API key in the request header:

```bash
# Set API key
export API_KEY="your-secure-api-key-here"

# Include in requests
curl -H "X-API-Key: $API_KEY" http://localhost:8765/api/...
```

#### Example API Calls

**Get Dashboard Statistics**
```bash
curl http://localhost:8765/api/stats
```

**Get Top 10 IP Addresses**
```bash
curl http://localhost:8765/api/logs/top-ips?limit=10
```

**Get Top URLs**
```bash
curl http://localhost:8765/api/logs/top-urls?limit=5
```

**Get Security Threats**
```bash
curl http://localhost:8765/api/security/threats
```

**Block an IP Address**
```bash
curl -X POST \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"ip": "192.168.1.100"}' \
  http://localhost:8765/api/security/block-ip
```

**Generate Report (JSON)**
```bash
curl http://localhost:8765/api/reports/generate?format=json
```

**Generate Report (CSV)**
```bash
curl http://localhost:8765/api/reports/generate?format=csv > report.csv
```

**Update Settings**
```bash
curl -X PUT \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"logFilePath": "/var/log/nginx/access.log", "updateInterval": 30}' \
  http://localhost:8765/api/settings
```

---

## 📚 API Documentation

### Base URL
```
http://localhost:8765/api
```

### Endpoints

#### Health Check
```
GET /api/health

Response:
{
  "status": "healthy",
  "timestamp": "2026-06-09T12:00:00.000000",
  "service": "nginx-inspector-api"
}
```

#### Dashboard Statistics
```
GET /api/stats

Parameters:
  - log_file (optional): Path to nginx log file

Response:
{
  "error": false,
  "data": {
    "totalRequests": 125480,
    "uniqueIps": 1250,
    "errors": 2847,
    "errors_4xx": 2500,
    "errors_5xx": 347,
    "statusCodes": {"200": 122633, "404": 2500, "500": 347, ...},
    "bandwidth": "2.34 GB",
    "threats": 34
  },
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Log Analysis
```
GET /api/logs/analysis

Parameters:
  - log_file (optional): Path to nginx log file
  - limit (optional): Max results (1-10000, default: 100)

Response:
{
  "error": false,
  "data": {
    "totalRequests": 125480,
    "statusCodeDistribution": {...},
    "topUrls": {"/api/v1/users": 2847, ...},
    "uniqueIps": 1250
  },
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Top IPs
```
GET /api/logs/top-ips

Parameters:
  - log_file (optional): Path to nginx log file
  - limit (optional): Max IPs (1-100, default: 10)

Response:
{
  "error": false,
  "data": [
    {
      "address": "192.168.1.100",
      "requests": 5234,
      "status": "Clean",
      "lastSeen": "2026-06-09T12:00:00.000000"
    },
    ...
  ],
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Top URLs
```
GET /api/logs/top-urls

Parameters:
  - log_file (optional): Path to nginx log file
  - limit (optional): Max URLs (1-100, default: 10)

Response:
{
  "error": false,
  "data": [
    {
      "path": "/api/v1/users",
      "requests": 2847,
      "avgResponseTime": 150,
      "statusCode": "200 OK"
    },
    ...
  ],
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Real-time Logs
```
GET /api/logs/realtime

Parameters:
  - log_file (optional): Path to nginx log file
  - lines (optional): Number of lines (1-1000, default: 20)

Response:
{
  "error": false,
  "data": [
    "192.168.1.100 - - [09/Jun/2026:12:00:00 +0000] \"GET /api/v1/users HTTP/1.1\" 200 1234",
    ...
  ],
  "count": 20,
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Security Threats
```
GET /api/security/threats

Parameters:
  - log_file (optional): Path to nginx log file
  - threat_type (optional): Filter by type (sql_injection, xss, scanner, etc.)

Response:
{
  "error": false,
  "data": [
    {
      "type": "sql_injection",
      "severity": "critical",
      "ip": "45.142.182.99",
      "url": "/search?q=1' OR '1'='1",
      "timestamp": "2026-06-09T12:00:00.000000",
      "logLine": "45.142.182.99 - - [09/Jun/2026:12:00:00 +0000] \"GET /search?q=1' OR '1'='1 HTTP/1.1\" 200"
    },
    ...
  ],
  "count": 34,
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Block IP (Requires API Key)
```
POST /api/security/block-ip

Headers:
  X-API-Key: your-api-key

Body:
{
  "ip": "192.168.1.100"
}

Response:
{
  "error": false,
  "message": "IP 192.168.1.100 has been blocked",
  "ip": "192.168.1.100",
  "action": "block",
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

#### Generate Report
```
GET /api/reports/generate

Parameters:
  - log_file (optional): Path to nginx log file
  - format (optional): json, csv, html (default: json)

Response (JSON):
{
  "error": false,
  "report": {
    "generatedAt": "2026-06-09T12:00:00.000000",
    "logFile": "/var/log/nginx/access.log",
    "totalRequests": 125480,
    "uniqueIPs": 1250,
    "errors4xx": 2500,
    "errors5xx": 347,
    "statusCodeDistribution": {...}
  }
}
```

#### Settings
```
GET /api/settings

Response:
{
  "error": false,
  "data": {
    "logFilePath": "/var/log/nginx/access.log",
    "updateInterval": 30,
    "apiKey": "SET",
    "debugMode": false
  },
  "timestamp": "2026-06-09T12:00:00.000000"
}

PUT /api/settings (Requires API Key)

Headers:
  X-API-Key: your-api-key

Body:
{
  "logFilePath": "/var/log/nginx/access.log",
  "updateInterval": 30
}

Response:
{
  "error": false,
  "message": "Settings updated successfully",
  "data": {...},
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

### Error Handling

All API responses follow a consistent error format:

```json
{
  "error": true,
  "message": "Descriptive error message",
  "timestamp": "2026-06-09T12:00:00.000000"
}
```

**HTTP Status Codes:**
- `200`: Success
- `400`: Bad Request (validation error)
- `401`: Unauthorized (missing/invalid API key)
- `404`: Not Found
- `500`: Internal Server Error
- `504`: Gateway Timeout

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the project root:

```bash
# Copy from example
cp .env.example .env

# Edit the file
nano .env
```

**Available Configuration:**

```env
# API Server Settings
HOST=0.0.0.0
PORT=8765
DEBUG=False

# API Key (CHANGE THIS IN PRODUCTION!)
NGINX_INSPECTOR_API_KEY=your-secure-api-key-here

# Nginx Log File Path
DEFAULT_LOG_FILE=/var/log/nginx/access.log

# CORS Settings
CORS_ORIGINS=*
```

### Nginx Log Format

Nginx Inspector expects the standard Nginx combined log format:

```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

If your Nginx uses a custom format, it may need adjustment in the log parser.

### Systemd Service

The service is automatically configured during installation. To manage it:

```bash
# Start service
sudo systemctl start nginx-inspector

# Stop service
sudo systemctl stop nginx-inspector

# Restart service
sudo systemctl restart nginx-inspector

# Enable auto-start on boot
sudo systemctl enable nginx-inspector

# Disable auto-start
sudo systemctl disable nginx-inspector

# View logs
sudo journalctl -u nginx-inspector -f
sudo journalctl -u nginx-inspector --lines=100
```

---

## 🌐 Web Dashboard

### Accessing the Dashboard

**Local Development:**
```
http://localhost:8080
```

**Remote Server:**
```
http://your-server-ip:8080
```

### Dashboard Features

**Dark Mode**
- Click the moon icon (☀️/🌙) in the top-right to toggle themes
- Preference is saved in browser localStorage

**Real-time Updates**
- Dashboard auto-refreshes every 30 seconds
- Click "Refresh" button on any page for immediate update

**Navigation**
- Click sidebar menu items to switch pages
- Mobile: Click hamburger menu (☰) to toggle sidebar
- Links are auto-generated based on available data

**Responsive Design**
- Desktop (1200px+): Full sidebar and all features
- Tablet (768px-1199px): Collapsible sidebar
- Mobile (<768px): Hidden sidebar, hamburger menu

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Port Already in Use
**Problem:** "Address already in use"

**Solution:**
```bash
# Find process using port 8765
sudo lsof -i :8765

# Kill the process
sudo kill -9 <PID>

# Or change port in .env
PORT=8766
```

#### 2. Permission Denied
**Problem:** "Permission denied" when running commands

**Solution:**
```bash
# Add user to appropriate groups
sudo usermod -aG nginx $USER
sudo usermod -aG nginx-inspector $USER

# Log out and log in
exit
```

#### 3. Log File Not Found
**Problem:** "Log file not found: /var/log/nginx/access.log"

**Solution:**
```bash
# Check if Nginx is running
sudo systemctl status nginx

# Find correct log file path
sudo find /var/log -name "*access.log" -o -name "*access.log.*"

# Update .env with correct path
DEFAULT_LOG_FILE=/path/to/correct/access.log

# Restart service
sudo systemctl restart nginx-inspector
```

#### 4. API Key Not Working
**Problem:** "Invalid API key" error

**Solution:**
```bash
# Check API key is set in .env
grep NGINX_INSPECTOR_API_KEY .env

# Make sure key is in request header
curl -H "X-API-Key: your-api-key" http://localhost:8765/api/stats
```

#### 5. CORS Errors in Browser
**Problem:** "Cross-Origin Request Blocked"

**Solution:**
```bash
# Check if CORS is enabled in .env
CORS_ORIGINS=*

# For specific domains:
CORS_ORIGINS=https://yourdomain.com,http://localhost:3000

# Restart API server
sudo systemctl restart nginx-inspector
```

#### 6. High Memory Usage
**Problem:** API server consuming too much memory

**Solution:**
```bash
# Check log file size
du -sh /var/log/nginx/access.log

# Rotate logs if too large
sudo logrotate /etc/logrotate.d/nginx

# Clear old logs
sudo rm /var/log/nginx/access.log.*

# Restart service
sudo systemctl restart nginx-inspector
```

### Debug Mode

Enable debug mode for detailed logging:

```env
DEBUG=True
```

View detailed logs:
```bash
sudo journalctl -u nginx-inspector -f --output=verbose
```

---

## 📊 Performance Tips

### For Large Log Files

1. **Use Log Rotation:**
   ```bash
   sudo nano /etc/logrotate.d/nginx
   ```
   Ensure logs are rotated daily

2. **Increase Refresh Interval:**
   - Set `updateInterval` to 60+ seconds in Settings
   - Reduces CPU usage on large files

3. **Filter Specific Time Period:**
   ```bash
   # Analyze only recent logs
   tail -f /var/log/nginx/access.log | wc -l
   ```

4. **Use Multiple Instances:**
   - Run separate API instances for different log files
   - Use reverse proxy (Nginx/Apache) to load balance

### Database Optimization
- Clear cache periodically: `systemctl restart nginx-inspector`
- Archive old logs separately
- Use SSD for better I/O performance

---

## 🔐 Security Best Practices

### API Security

1. **Change Default API Key**
   ```env
   NGINX_INSPECTOR_API_KEY=generate-secure-random-key
   ```

2. **Enable HTTPS in Production**
   ```bash
   # Use reverse proxy (Nginx) with SSL certificate
   sudo certbot certonly --standalone -d yourdomain.com
   ```

3. **Limit API Access**
   ```bash
   # Use firewall rules
   sudo ufw allow from 192.168.1.0/24 to any port 8765
   sudo ufw deny from any to any port 8765
   ```

4. **Regular Updates**
   ```bash
   cd /usr/local/nginx-inspector
   git pull origin master
   sudo systemctl restart nginx-inspector
   ```

### Log File Security

- Nginx logs may contain sensitive information
- Restrict permissions: `sudo chmod 640 /var/log/nginx/access.log`
- Use dedicated log analysis account with limited permissions
- Don't expose logs publicly

---

## 📈 Monitoring & Alerts

### Monitor Service Health
```bash
# Check if service is running
sudo systemctl is-active nginx-inspector

# Monitor in real-time
watch -n 5 'systemctl status nginx-inspector'
```

### Set Up Alerts (Optional)
Create a cron job to monitor:
```bash
# Edit crontab
crontab -e

# Add monitoring script
*/5 * * * * /usr/local/nginx-inspector/scripts/health-check.sh
```

---

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Types of Contributions
- 🐛 Bug Reports
- ✨ Feature Requests
- 📝 Documentation Improvements
- 🔧 Code Fixes
- 🎨 UI/UX Improvements

### Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/nginx-inspector.git
   cd nginx-inspector
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow existing code style
   - Add comments for complex logic
   - Update documentation

4. **Test Your Changes**
   ```bash
   # Run tests
   python -m pytest tests/

   # Test API endpoints
   curl http://localhost:8765/api/health
   ```

5. **Commit & Push**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Describe what you changed
   - Reference any related issues
   - Add screenshots for UI changes

### Code Style Guidelines
- Python: Follow PEP 8
- JavaScript: Use ESLint configuration
- Comments: Clear and concise
- Commit messages: Use conventional commits

---

## 📞 Support & Community

- **GitHub Issues**: [Report bugs or request features](https://github.com/shuvo-halder/nginx-inspector/issues)
- **Discussions**: [Ask questions and share ideas](https://github.com/shuvo-halder/nginx-inspector/discussions)
- **Wiki**: [Community documentation](https://github.com/shuvo-halder/nginx-inspector/wiki)

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 Shuvo Halder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- Built with [Flask](https://flask.palletsprojects.com/) - Python web framework
- UI powered by [Chart.js](https://www.chartjs.org/) - JavaScript charting
- Icons from [Font Awesome](https://fontawesome.com/) - Icon library
- Inspired by security best practices from OWASP

---

## 📊 Project Statistics

- **Lines of Code**: 5000+
- **API Endpoints**: 12+
- **Threat Detection Patterns**: 20+
- **Test Coverage**: In Development
- **Contributors**: Community welcome!

---

## 🚀 Roadmap

### v2.0 (Planned)
- [ ] Database support for historical data
- [ ] User authentication & authorization
- [ ] WebSocket real-time updates
- [ ] Advanced filtering & search
- [ ] Custom dashboard widgets
- [ ] Alert notifications
- [ ] API rate limiting
- [ ] Request/response caching

### v3.0 (Future)
- [ ] Multi-server monitoring
- [ ] Machine learning anomaly detection
- [ ] Advanced threat intelligence
- [ ] Plugin system for extensibility
- [ ] Mobile app (iOS/Android)

---

<div align="center">

### Made with ❤️ by [Shuvo Halder](https://github.com/shuvo-halder)

[⬆ Back to Top](#-nginx-inspector)

</div>
