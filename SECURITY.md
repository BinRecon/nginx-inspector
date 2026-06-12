# 🔒 Nginx Inspector Security Guide

## Overview
This document provides comprehensive security guidelines for Nginx Inspector, including API key management, authentication, and best practices.

---

## 🔐 API Key Management

### Generating a Secure API Key

**Method 1: Using Python (Recommended)**
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

**Method 2: Using OpenSSL**
```bash
openssl rand -hex 32
```

**Method 3: Using /dev/urandom**
```bash
cat /dev/urandom | head -c 32 | od -An -tx1 | tr -d ' '
```

### Setting the API Key

**During Installation:**
The `install.sh` script automatically generates and configures a secure API key:
```bash
sudo bash install.sh
# API key is generated and saved to /usr/local/nginx-inspector/.env
```

**Manual Configuration:**
```bash
# Generate a new key
NEW_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Update .env file
sudo nano /usr/local/nginx-inspector/.env

# Change this line:
NGINX_INSPECTOR_API_KEY=your-secure-api-key-here
# To:
NGINX_INSPECTOR_API_KEY=$NEW_KEY

# Restart the service
sudo systemctl restart nginx-inspector
```

**Using Environment Variables:**
```bash
export NGINX_INSPECTOR_API_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
python api/api-server.py
```

---

## 🛡️ Authentication

### Protected Endpoints
The following endpoints require API key authentication via the `X-API-Key` header:

- `POST /api/security/block-ip` - Block IP addresses
- `PUT /api/settings` - Update application settings
- `GET /api/reports/generate` - Generate reports (recommended)

### API Key Authentication

**Using cURL:**
```bash
# Set API key
API_KEY="your-api-key-here"

# Example: Block an IP address
curl -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"ip": "192.168.1.100"}' \
  http://localhost:8765/api/security/block-ip
```

**Using Python requests:**
```python
import requests

api_key = "your-api-key-here"
headers = {"X-API-Key": api_key}

response = requests.post(
    "http://localhost:8765/api/security/block-ip",
    json={"ip": "192.168.1.100"},
    headers=headers
)
print(response.json())
```

**Using JavaScript/Node.js:**
```javascript
const apiKey = "your-api-key-here";

fetch('http://localhost:8765/api/security/block-ip', {
    method: 'POST',
    headers: {
        'X-API-Key': apiKey,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ ip: '192.168.1.100' })
})
.then(response => response.json())
.then(data => console.log(data));
```

---

## 🔑 Security Best Practices

### 1. API Key Security
- ✅ **DO**: Generate unique, cryptographically secure keys
- ✅ **DO**: Store keys in environment variables or `.env` files
- ✅ **DO**: Restrict file permissions: `chmod 600 .env`
- ✅ **DO**: Rotate keys regularly (every 90 days recommended)
- ✅ **DO**: Use different keys for different environments
- ❌ **DON'T**: Commit API keys to version control
- ❌ **DON'T**: Share keys via email or chat
- ❌ **DON'T**: Use the same key for multiple services

### 2. Network Security
```env
# ✅ SECURE: Listen only on localhost
HOST=127.0.0.1
API_PORT=8765

# ⚠️ RISKY: Listen on all interfaces (use with firewall)
HOST=0.0.0.0
```

**If you need remote access:**
1. Use a reverse proxy (Nginx/Apache) with SSL/TLS
2. Implement additional authentication (OAuth2, SAML)
3. Use a firewall to restrict access to trusted IPs
4. Enable VPN or SSH tunneling

```bash
# Example: Firewall restriction (ufw)
sudo ufw allow from 192.168.1.0/24 to any port 8765
sudo ufw deny from any to any port 8765
```

### 3. CORS Configuration
```env
# ❌ INSECURE: Allow all origins
CORS_ORIGINS=*

# ✅ SECURE: Specific domains only
CORS_ORIGINS=https://yourdomain.com

# ✅ SECURE: Multiple specific domains
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

### 4. HTTPS/TLS Configuration
Set up a reverse proxy with SSL certificates:

**Nginx Example:**
```nginx
server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location /api {
        proxy_pass http://localhost:8765;
        proxy_set_header X-API-Key $http_x_api_key;
    }
}
```

### 5. Debug Mode
```env
# ❌ NEVER in production
DEBUG=True

# ✅ Production setting
DEBUG=False
```

---

## 🚨 Common Security Issues & Solutions

### Issue: API Key Exposed in Logs
**Problem:** API keys visible in application logs

**Solution:**
```python
# Nginx Inspector masks API keys in logs
# Only first 10 characters are logged: "your-sec..."
logger.warning(f"Invalid API key attempt: {api_key[:10]}...")
```

### Issue: Timing Attacks
**Problem:** Attackers can guess API keys using response time differences

**Solution:**
Nginx Inspector uses constant-time comparison:
```python
import secrets
if not secrets.compare_digest(user_key, API_KEY):
    raise AuthenticationError("Invalid API key")
```

### Issue: Path Traversal
**Problem:** Attackers access files outside log directory

**Solution:**
```python
# Nginx Inspector validates log file paths
if ".." in log_file:
    raise ValidationError("Invalid log file path: path traversal detected")
```

### Issue: Shell Injection
**Problem:** Attackers execute arbitrary commands

**Solution:**
```bash
# Nginx Inspector properly quotes all variables
grep -Ei "pattern" "$LOGFILE"  # Correct
grep -Ei "pattern" $LOGFILE    # Vulnerable
```

---

## 📋 Security Checklist

Before deploying to production:

- [ ] Generate a new, secure API key
- [ ] Set `DEBUG=False`
- [ ] Set `HOST=127.0.0.1` (or use reverse proxy)
- [ ] Configure CORS to specific domains
- [ ] Set file permissions: `chmod 600 .env`
- [ ] Configure HTTPS/TLS with reverse proxy
- [ ] Restrict firewall access to trusted IPs
- [ ] Enable log rotation for nginx logs
- [ ] Set up monitoring and alerting
- [ ] Document security procedures
- [ ] Plan API key rotation schedule
- [ ] Review application logs regularly

---

## 🔄 Key Rotation

### Rotate API Key Every 90 Days

**Step 1: Generate New Key**
```bash
NEW_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
echo "New key: $NEW_KEY"
```

**Step 2: Update .env**
```bash
sudo nano /usr/local/nginx-inspector/.env
# Update NGINX_INSPECTOR_API_KEY with new value
```

**Step 3: Update Clients**
Update all applications using the old key with the new key

**Step 4: Restart Service**
```bash
sudo systemctl restart nginx-inspector
```

**Step 5: Verify**
```bash
curl -H "X-API-Key: $NEW_KEY" http://localhost:8765/api/health
```

---

## 📊 Monitoring & Logging

### View Security Logs
```bash
# View all API authentication attempts
sudo journalctl -u nginx-inspector -f | grep "API\|Error\|Warning"

# View authentication failures
sudo journalctl -u nginx-inspector -f | grep "Invalid API key"

# View last 100 lines
sudo journalctl -u nginx-inspector -n 100
```

### Alert on Failed Authentication
```bash
# Create a cron job to check for failed auth attempts
0 */6 * * * /usr/local/nginx-inspector/scripts/check-failed-auth.sh
```

---

## 🔗 Related Documentation

- [README.md](../README.md) - Full project documentation
- [.env.example](../.env.example) - Configuration example
- [API Documentation](../README.md#-api-documentation) - API endpoints
- [Troubleshooting](../README.md#-troubleshooting) - Common issues

---

## 📞 Security Issues

If you discover a security vulnerability:

1. **DO NOT** open a public GitHub issue
2. Email details to: `security@example.com` (add your contact)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if you have one)

4. Allow 48 hours for response
5. Responsible disclosure appreciated

---

## 🔗 Security Resources

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Python secrets module](https://docs.python.org/3/library/secrets.html)
- [API Key Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/API_Key_Storage_Cheat_Sheet.html)
- [Environment Variables Security](https://12factor.net/config)

---

**Last Updated:** June 2026  
**Version:** 1.0.0  
**Status:** Production Ready
