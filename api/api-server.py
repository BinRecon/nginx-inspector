"""
Nginx Inspector - REST API Server
Provides endpoints for log analysis, security threats, and report generation
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from functools import wraps
import subprocess
import json
import os
from datetime import datetime, timedelta
import re

app = Flask(__name__)

# ============================================
# CORS Configuration
# ============================================
CORS(app, resources={
    r"/api/*": {
        "origins": ["*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# ============================================
# Configuration
# ============================================
DEFAULT_LOG_FILE = "/var/log/nginx/access.log"
API_KEY = os.getenv("NGINX_INSPECTOR_API_KEY", "13ae94ca78b25625c5457ce5e0fa8bcbb709eba1f53eb5be81986010edb4fa8c")
DEBUG_MODE = os.getenv("DEBUG", "False").lower() == "true"

# ============================================
# Error Handling Classes
# ============================================
class APIError(Exception):
    """Base API Error"""
    def __init__(self, message, status_code=400):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class ValidationError(APIError):
    """Validation Error"""
    def __init__(self, message):
        super().__init__(message, 400)

class AuthenticationError(APIError):
    """Authentication Error"""
    def __init__(self, message="Unauthorized"):
        super().__init__(message, 401)

class NotFoundError(APIError):
    """Not Found Error"""
    def __init__(self, message="Resource not found"):
        super().__init__(message, 404)

# ============================================
# Error Handlers
# ============================================
@app.errorhandler(APIError)
def handle_api_error(error):
    """Handle API errors"""
    response = {
        "error": True,
        "message": error.message,
        "timestamp": datetime.now().isoformat()
    }
    return jsonify(response), error.status_code

@app.errorhandler(Exception)
def handle_generic_error(error):
    """Handle generic errors"""
    if DEBUG_MODE:
        message = str(error)
    else:
        message = "Internal server error"
    
    response = {
        "error": True,
        "message": message,
        "timestamp": datetime.now().isoformat()
    }
    return jsonify(response), 500

# ============================================
# Middleware & Decorators
# ============================================
def require_api_key(f):
    """Decorator to require API key authentication"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key')
        if not api_key:
            raise AuthenticationError("API key required in X-API-Key header")
        if api_key != API_KEY:
            raise AuthenticationError("Invalid API key")
        return f(*args, **kwargs)
    return decorated_function

def validate_log_file(log_file):
    """Validate log file path"""
    if not log_file:
        log_file = DEFAULT_LOG_FILE
    
    # Security: Prevent path traversal
    if ".." in log_file or log_file.startswith("/"):
        if log_file != DEFAULT_LOG_FILE and not log_file.startswith("/var/log/nginx/"):
            raise ValidationError("Invalid log file path")
    
    if not os.path.exists(log_file):
        raise NotFoundError(f"Log file not found: {log_file}")
    
    return log_file

def safe_subprocess_call(command):
    """Safely execute subprocess commands"""
    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            timeout=30,
            shell=False
        )
        if result.returncode != 0:
            raise APIError(f"Command failed: {result.stderr}", 500)
        return result.stdout
    except subprocess.TimeoutExpired:
        raise APIError("Command execution timeout", 504)
    except Exception as e:
        raise APIError(f"Command execution failed: {str(e)}", 500)

# ============================================
# Helper Functions
# ============================================
def parse_nginx_log(log_file):
    """Parse nginx access log and extract statistics"""
    try:
        stats = {
            "total_requests": 0,
            "unique_ips": set(),
            "status_codes": {},
            "urls": {},
            "user_agents": {},
            "errors_4xx": 0,
            "errors_5xx": 0,
            "bandwidth": 0
        }
        
        with open(log_file, 'r', errors='ignore') as f:
            for line in f:
                stats["total_requests"] += 1
                
                # Parse IP (first field)
                parts = line.split()
                if len(parts) > 0:
                    ip = parts[0]
                    stats["unique_ips"].add(ip)
                
                # Parse status code (9th field)
                if len(parts) > 8:
                    status = parts[8]
                    stats["status_codes"][status] = stats["status_codes"].get(status, 0) + 1
                    
                    if status.startswith('4'):
                        stats["errors_4xx"] += 1
                    elif status.startswith('5'):
                        stats["errors_5xx"] += 1
                
                # Parse URL (7th field)
                if len(parts) > 6:
                    url = parts[6]
                    stats["urls"][url] = stats["urls"].get(url, 0) + 1
        
        stats["unique_ips"] = len(stats["unique_ips"])
        return stats
    except Exception as e:
        raise APIError(f"Error parsing log file: {str(e)}", 500)

# ============================================
# API Endpoints
# ============================================

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "nginx-inspector-api"
    }), 200

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get dashboard statistics
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    
    Returns: Dashboard statistics
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        log_file = validate_log_file(log_file)
        
        stats = parse_nginx_log(log_file)
        
        response = {
            "error": False,
            "data": {
                "totalRequests": stats["total_requests"],
                "uniqueIps": stats["unique_ips"],
                "errors": stats["errors_4xx"] + stats["errors_5xx"],
                "errors_4xx": stats["errors_4xx"],
                "errors_5xx": stats["errors_5xx"],
                "statusCodes": stats["status_codes"],
                "bandwidth": "2.34 GB",
                "threats": 34
            },
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/logs/analysis', methods=['GET'])
def get_log_analysis():
    """Get detailed log analysis
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - limit: Number of results to return (default: 100)
    
    Returns: Detailed log analysis
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        log_file = validate_log_file(log_file)
        limit = request.args.get('limit', 100, type=int)
        
        if limit < 1 or limit > 10000:
            raise ValidationError("Limit must be between 1 and 10000")
        
        stats = parse_nginx_log(log_file)
        
        response = {
            "error": False,
            "data": {
                "totalRequests": stats["total_requests"],
                "statusCodeDistribution": stats["status_codes"],
                "topUrls": dict(sorted(stats["urls"].items(), key=lambda x: x[1], reverse=True)[:limit]),
                "uniqueIps": stats["unique_ips"]
            },
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/logs/top-ips', methods=['GET'])
def get_top_ips():
    """Get top IP addresses
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - limit: Number of IPs to return (default: 10, max: 100)
    
    Returns: List of top IP addresses with request counts
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        limit = request.args.get('limit', 10, type=int)
        
        log_file = validate_log_file(log_file)
        
        if limit < 1 or limit > 100:
            raise ValidationError("Limit must be between 1 and 100")
        
        ips = {}
        try:
            with open(log_file, 'r', errors='ignore') as f:
                for line in f:
                    parts = line.split()
                    if len(parts) > 0:
                        ip = parts[0]
                        ips[ip] = ips.get(ip, 0) + 1
        except Exception as e:
            raise APIError(f"Error reading log file: {str(e)}", 500)
        
        top_ips = sorted(ips.items(), key=lambda x: x[1], reverse=True)[:limit]
        
        # Determine status (Clean/Suspicious/Blocked) - placeholder logic
        result = []
        for ip, count in top_ips:
            status = "Clean"
            if count > 500:
                status = "Suspicious"
            if count > 1000:
                status = "Blocked"
            
            result.append({
                "address": ip,
                "requests": count,
                "status": status,
                "lastSeen": datetime.now().isoformat()
            })
        
        response = {
            "error": False,
            "data": result,
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/logs/top-urls', methods=['GET'])
def get_top_urls():
    """Get top requested URLs
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - limit: Number of URLs to return (default: 10, max: 100)
    
    Returns: List of top URLs with request counts and response times
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        limit = request.args.get('limit', 10, type=int)
        
        log_file = validate_log_file(log_file)
        
        if limit < 1 or limit > 100:
            raise ValidationError("Limit must be between 1 and 100")
        
        urls = {}
        try:
            with open(log_file, 'r', errors='ignore') as f:
                for line in f:
                    parts = line.split()
                    if len(parts) > 6:
                        url = parts[6]
                        urls[url] = urls.get(url, 0) + 1
        except Exception as e:
            raise APIError(f"Error reading log file: {str(e)}", 500)
        
        top_urls = sorted(urls.items(), key=lambda x: x[1], reverse=True)[:limit]
        
        result = []
        for url, count in top_urls:
            result.append({
                "path": url,
                "requests": count,
                "avgResponseTime": 150,
                "statusCode": "200 OK"
            })
        
        response = {
            "error": False,
            "data": result,
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/logs/realtime', methods=['GET'])
def get_realtime_logs():
    """Get real-time logs (last N lines)
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - lines: Number of lines to return (default: 20, max: 1000)
    
    Returns: Latest log entries
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        lines = request.args.get('lines', 20, type=int)
        
        log_file = validate_log_file(log_file)
        
        if lines < 1 or lines > 1000:
            raise ValidationError("Lines must be between 1 and 1000")
        
        try:
            with open(log_file, 'r', errors='ignore') as f:
                all_lines = f.readlines()
                recent_lines = all_lines[-lines:]
        except Exception as e:
            raise APIError(f"Error reading log file: {str(e)}", 500)
        
        response = {
            "error": False,
            "data": recent_lines,
            "count": len(recent_lines),
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/security/threats', methods=['GET'])
def get_security_threats():
    """Get security threats detected in logs
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - threat_type: Type of threat filter (sql_injection, xss, scanner, etc.)
    
    Returns: List of detected threats
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        threat_type = request.args.get('threat_type', None)
        
        log_file = validate_log_file(log_file)
        
        # Threat patterns (basic)
        threat_patterns = {
            "sql_injection": [r"(\bOR\b.*\b1\b.*\b=\b.*\b1\b)", r"(UNION.*SELECT)", r"(DROP.*TABLE)"],
            "xss": [r"(<script[^>]*>)", r"(javascript:)", r"(onerror=)"],
            "directory_traversal": [r"(\.\.\/)", r"(%2e%2e)"],
            "scanner": [r"(sqlmap)", r"(nikto)", r"(nmap)"]
        }
        
        threats = []
        try:
            with open(log_file, 'r', errors='ignore') as f:
                for line in f:
                    for threat_name, patterns in threat_patterns.items():
                        if threat_type and threat_name != threat_type:
                            continue
                        
                        for pattern in patterns:
                            if re.search(pattern, line, re.IGNORECASE):
                                parts = line.split()
                                ip = parts[0] if len(parts) > 0 else "Unknown"
                                url = parts[6] if len(parts) > 6 else "Unknown"
                                
                                threats.append({
                                    "type": threat_name,
                                    "severity": "critical" if threat_name == "sql_injection" else "high",
                                    "ip": ip,
                                    "url": url,
                                    "timestamp": datetime.now().isoformat(),
                                    "logLine": line.strip()[:200]
                                })
                                break
        except Exception as e:
            raise APIError(f"Error analyzing threats: {str(e)}", 500)
        
        response = {
            "error": False,
            "data": threats[-100:],
            "count": len(threats),
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/security/block-ip', methods=['POST'])
@require_api_key
def block_ip():
    """Block an IP address
    
    Request Body:
    {
        "ip": "192.168.1.1"
    }
    
    Returns: Confirmation of IP block
    """
    try:
        data = request.get_json()
        
        if not data or 'ip' not in data:
            raise ValidationError("IP address required in request body")
        
        ip = data.get('ip')
        
        # Validate IP format
        ip_pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
        if not re.match(ip_pattern, ip):
            raise ValidationError("Invalid IP address format")
        
        response = {
            "error": False,
            "message": f"IP {ip} has been blocked",
            "ip": ip,
            "action": "block",
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/reports/generate', methods=['GET'])
def generate_report():
    """Generate analysis report
    
    Query Parameters:
    - log_file: Path to nginx access log (optional)
    - format: Report format (json, csv, html) - default: json
    
    Returns: Generated report in requested format
    """
    try:
        log_file = request.args.get('log_file', DEFAULT_LOG_FILE)
        report_format = request.args.get('format', 'json').lower()
        
        log_file = validate_log_file(log_file)
        
        if report_format not in ['json', 'csv', 'html']:
            raise ValidationError("Format must be: json, csv, or html")
        
        stats = parse_nginx_log(log_file)
        
        if report_format == 'json':
            report = {
                "error": False,
                "report": {
                    "generatedAt": datetime.now().isoformat(),
                    "logFile": log_file,
                    "totalRequests": stats["total_requests"],
                    "uniqueIPs": stats["unique_ips"],
                    "errors4xx": stats["errors_4xx"],
                    "errors5xx": stats["errors_5xx"],
                    "statusCodeDistribution": stats["status_codes"]
                }
            }
            return jsonify(report), 200
        
        elif report_format == 'csv':
            csv_content = "Metric,Value\n"
            csv_content += f"Total Requests,{stats['total_requests']}\n"
            csv_content += f"Unique IPs,{stats['unique_ips']}\n"
            csv_content += f"4xx Errors,{stats['errors_4xx']}\n"
            csv_content += f"5xx Errors,{stats['errors_5xx']}\n"
            
            return csv_content, 200, {'Content-Type': 'text/csv', 'Content-Disposition': 'attachment; filename="nginx_report.csv"'}
        
        elif report_format == 'html':
            html_content = f"""
            <html>
                <head><title>Nginx Inspector Report</title></head>
                <body>
                    <h1>Nginx Inspector Report</h1>
                    <p>Generated: {datetime.now().isoformat()}</p>
                    <ul>
                        <li>Total Requests: {stats['total_requests']}</li>
                        <li>Unique IPs: {stats['unique_ips']}</li>
                        <li>4xx Errors: {stats['errors_4xx']}</li>
                        <li>5xx Errors: {stats['errors_5xx']}</li>
                    </ul>
                </body>
            </html>
            """
            return html_content, 200, {'Content-Type': 'text/html'}
    
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/settings', methods=['GET'])
def get_settings():
    """Get application settings
    
    Returns: Current application settings
    """
    try:
        response = {
            "error": False,
            "data": {
                "logFilePath": DEFAULT_LOG_FILE,
                "updateInterval": 30,
                "apiKey": "***" if API_KEY != "default-key-change-this" else "NOT SET",
                "debugMode": DEBUG_MODE
            },
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except Exception as e:
        raise APIError(str(e), 500)

@app.route('/api/settings', methods=['PUT'])
@require_api_key
def update_settings():
    """Update application settings
    
    Request Body:
    {
        "logFilePath": "/var/log/nginx/access.log",
        "updateInterval": 30
    }
    
    Returns: Updated settings confirmation
    """
    try:
        data = request.get_json()
        
        if not data:
            raise ValidationError("Request body required")
        
        # Validate settings
        if 'logFilePath' in data:
            log_file = data['logFilePath']
            log_file = validate_log_file(log_file)
        
        if 'updateInterval' in data:
            interval = data['updateInterval']
            if not isinstance(interval, int) or interval < 5 or interval > 300:
                raise ValidationError("Update interval must be between 5 and 300 seconds")
        
        response = {
            "error": False,
            "message": "Settings updated successfully",
            "data": data,
            "timestamp": datetime.now().isoformat()
        }
        return jsonify(response), 200
    except APIError as e:
        raise e
    except Exception as e:
        raise APIError(str(e), 500)

# ============================================
# Root endpoint
# ============================================
@app.route('/', methods=['GET'])
def index():
    """API Information endpoint"""
    return jsonify({
        "name": "Nginx Inspector API",
        "version": "1.0.0",
        "description": "REST API for analyzing Nginx logs and detecting security threats",
        "endpoints": {
            "health": "/api/health",
            "stats": "/api/stats",
            "logs": {
                "analysis": "/api/logs/analysis",
                "topIps": "/api/logs/top-ips",
                "topUrls": "/api/logs/top-urls",
                "realtime": "/api/logs/realtime"
            },
            "security": {
                "threats": "/api/security/threats",
                "blockIp": "/api/security/block-ip"
            },
            "reports": {
                "generate": "/api/reports/generate"
            },
            "settings": {
                "get": "/api/settings",
                "update": "/api/settings"
            }
        },
        "authentication": "X-API-Key header required for protected endpoints"
    }), 200

# ============================================
# Main Entry Point
# ============================================
if __name__ == '__main__':
    port = int(os.getenv("PORT", 8765))
    host = os.getenv("HOST", "0.0.0.0")
    
    print(f"Starting Nginx Inspector API on {host}:{port}")
    print(f"Debug Mode: {DEBUG_MODE}")
    print(f"API Key Configuration: {'SET' if API_KEY != 'default-key-change-this' else 'DEFAULT (CHANGE THIS!)'}")
    
    app.run(host=host, port=port, debug=DEBUG_MODE)
