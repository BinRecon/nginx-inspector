#!/bin/bash

# Nginx Inspector Installation Script
# This script installs nginx-inspector and all its dependencies
# Security: Generates secure API key automatically during installation

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
INSTALL_DIR="/usr/local/nginx-inspector"
VENV_DIR="$INSTALL_DIR/venv"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handler
error_exit() {
    echo -e "${RED}✗ Error: $1${NC}"
    exit 1
}

success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if running on Linux
if [[ ! "$OSTYPE" == "linux"* ]]; then
    error_exit "This script only works on Linux systems"
fi

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then
    error_exit "This script must be run with sudo"
fi

echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Nginx Inspector Installation      ║${NC}"
echo -e "${CYAN}║    Version: 1.0.0                     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check prerequisites
info_msg "Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    warning_msg "Python3 not found. Installing..."
    apt-get update -qq || error_exit "Failed to update package list"
    apt-get install -y python3 > /dev/null || error_exit "Failed to install Python3"
    success_msg "Python3 installed"
fi

if ! command -v pip3 &> /dev/null; then
    warning_msg "pip3 not found. Installing..."
    apt-get install -y python3-pip > /dev/null || error_exit "Failed to install pip3"
    success_msg "pip3 installed"
fi

if ! python3 -m venv --help &> /dev/null; then
    warning_msg "python3-venv not found. Installing..."
    apt-get install -y python3-venv > /dev/null || error_exit "Failed to install python3-venv"
    success_msg "python3-venv installed"
fi

success_msg "All prerequisites met"
echo ""

# Step 2: Create installation directory
info_msg "Setting up installation directory..."

if [ -d "$INSTALL_DIR" ]; then
    warning_msg "Removing existing installation at $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
fi

mkdir -p "$INSTALL_DIR" || error_exit "Failed to create installation directory"
success_msg "Installation directory created: $INSTALL_DIR"
echo ""

# Step 3: Copy files
info_msg "Copying application files..."

if [ ! -d "$SCRIPT_DIR/bin" ]; then
    error_exit "Source directory 'bin' not found. Run from repository root."
fi

cp -r "$SCRIPT_DIR/bin" "$INSTALL_DIR/" || error_exit "Failed to copy bin directory"
cp -r "$SCRIPT_DIR/api" "$INSTALL_DIR/" || error_exit "Failed to copy api directory"
cp -r "$SCRIPT_DIR/web" "$INSTALL_DIR/" || error_exit "Failed to copy web directory"
cp -r "$SCRIPT_DIR/service" "$INSTALL_DIR/" 2>/dev/null || warning_msg "Service directory not found"

if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/" || error_exit "Failed to copy requirements.txt"
fi

success_msg "Application files copied"
echo ""

# Step 4: Setup .env file with secure API key generation
info_msg "Setting up .env configuration file..."

# Generate secure API key
info_msg "Generating secure API key..."
if command -v python3 &> /dev/null; then
    GENERATED_API_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))" 2>/dev/null)
    if [ -z "$GENERATED_API_KEY" ]; then
        # Fallback if secrets module not available
        GENERATED_API_KEY=$(python3 -c "import os; print(os.urandom(32).hex())" 2>/dev/null)
    fi
    if [ -z "$GENERATED_API_KEY" ]; then
        # Last resort fallback
        GENERATED_API_KEY=$(openssl rand -hex 32)
    fi
    success_msg "Secure API key generated"
else
    GENERATED_API_KEY=$(openssl rand -hex 32)
    success_msg "Secure API key generated using OpenSSL"
fi

if [ ! -f "$INSTALL_DIR/.env" ]; then
    if [ -f "$SCRIPT_DIR/.env.example" ]; then
        cp "$SCRIPT_DIR/.env.example" "$INSTALL_DIR/.env" || error_exit "Failed to copy .env.example"
        success_msg ".env file created from .env.example"
    else
        warning_msg ".env.example not found, creating default .env"
        cat > "$INSTALL_DIR/.env" << 'EOF'
# Nginx Inspector API Configuration
# =====================================
# See .env.example for detailed documentation

# API Server Settings
HOST=127.0.0.1
API_PORT=8765
DEBUG=False

# Web Dashboard Settings
WEB_PORT=8080

# API Key - GENERATED SECURELY
NGINX_INSPECTOR_API_KEY=PLACEHOLDER_API_KEY

# Nginx Log File Path
DEFAULT_LOG_FILE=/var/log/nginx/access.log

# CORS Settings
CORS_ORIGINS=http://localhost:8080
EOF
        success_msg "Default .env file created"
    fi
    
    # Replace API key placeholder with generated key
    if [ -n "$GENERATED_API_KEY" ]; then
        sed -i "s|PLACEHOLDER_API_KEY|$GENERATED_API_KEY|g" "$INSTALL_DIR/.env"
        sed -i "s|your-secure-api-key-here|$GENERATED_API_KEY|g" "$INSTALL_DIR/.env"
        success_msg "API key configured in .env"
    fi
else
    warning_msg ".env file already exists, skipping..."
    info_msg "To generate a new API key, run:"
    echo "   python3 -c \"import secrets; print(secrets.token_hex(32))\""
    echo "   Then update NGINX_INSPECTOR_API_KEY in: $INSTALL_DIR/.env"
fi
echo ""

# Step 5: Setup permissions
info_msg "Setting up permissions..."

chmod 755 "$INSTALL_DIR" || error_exit "Failed to set directory permissions"
chmod +x "$INSTALL_DIR/bin/nginx-inspector" || error_exit "Failed to set nginx-inspector permissions"
chmod +x "$INSTALL_DIR/bin"/*.sh 2>/dev/null || true
chmod 600 "$INSTALL_DIR/.env" || warning_msg "Could not set .env permissions (required for security)"

success_msg "Permissions set correctly"
echo ""

# Step 6: Create symbolic link
info_msg "Creating command-line interface..."

# Remove old symlink if it exists
if [ -L "/usr/local/bin/nginx-inspector" ]; then
    rm "/usr/local/bin/nginx-inspector"
fi

ln -s "$INSTALL_DIR/bin/nginx-inspector" "/usr/local/bin/nginx-inspector" || error_exit "Failed to create symlink"
success_msg "Command 'nginx-inspector' is now available globally"
echo ""

# Step 7: Create Python virtual environment
info_msg "Setting up Python virtual environment..."

if [ -d "$VENV_DIR" ]; then
    rm -rf "$VENV_DIR"
fi

python3 -m venv "$VENV_DIR" || error_exit "Failed to create virtual environment"
success_msg "Virtual environment created"
echo ""

# Step 8: Install Python dependencies
info_msg "Installing Python dependencies..."

if [ ! -f "$INSTALL_DIR/requirements.txt" ]; then
    error_exit "requirements.txt not found at $INSTALL_DIR/requirements.txt"
fi

"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel > /dev/null 2>&1 || warning_msg "Failed to upgrade pip"
if "$VENV_DIR/bin/pip" install -r "$INSTALL_DIR/requirements.txt" > /dev/null 2>&1; then
    success_msg "Python dependencies installed successfully"
else
    error_exit "Failed to install Python dependencies"
fi
echo ""

# Step 9: Setup systemd service
info_msg "Setting up systemd service..."

if [ -f "$INSTALL_DIR/service/nginx-inspector.service" ]; then
    cp "$INSTALL_DIR/service/nginx-inspector.service" "/etc/systemd/system/" || error_exit "Failed to copy service file"
    
    # Update paths in service file
    sed -i "s|/usr/local/nginx-inspector|$INSTALL_DIR|g" "/etc/systemd/system/nginx-inspector.service"
    
    systemctl daemon-reload || error_exit "Failed to reload systemd daemon"
    systemctl enable nginx-inspector > /dev/null 2>&1 || error_exit "Failed to enable service"
    
    success_msg "Systemd service configured"
else
    warning_msg "Service file not found, skipping systemd setup"
fi
echo ""

# Step 10: Verify installation
info_msg "Verifying installation..."

if [ ! -f "/usr/local/bin/nginx-inspector" ]; then
    error_exit "Installation verification failed: nginx-inspector command not found"
fi

if [ ! -d "$VENV_DIR" ]; then
    error_exit "Installation verification failed: virtual environment not found"
fi

if ! "$VENV_DIR/bin/python" -c "import flask" 2>/dev/null; then
    error_exit "Installation verification failed: Flask not installed"
fi

if [ ! -f "$INSTALL_DIR/.env" ]; then
    error_exit "Installation verification failed: .env file not found"
fi

success_msg "Installation verified successfully"
echo ""

# Step 11: Display installation summary
echo -e "${CYAN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Installation Complete! ✓                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📦 Installation Directory:${NC}"
echo "   $INSTALL_DIR"
echo ""
echo -e "${GREEN}🔐 Security Configuration:${NC}"
echo "   ✓ Secure API key generated and saved to .env"
echo "   ✓ .env file permissions: 600 (restricted access)"
echo "   ✓ API key will NOT be logged or displayed"
echo ""
echo -e "${GREEN}🚀 Getting Started:${NC}"
echo ""
echo -e "   ${CYAN}1. Review configuration (optional):${NC}"
echo "      sudo nano $INSTALL_DIR/.env"
echo "      (Your API key has been automatically generated)"
echo ""
echo -e "   ${CYAN}2. Start service:${NC}"
echo "      sudo systemctl start nginx-inspector"
echo ""
echo -e "   ${CYAN}3. Enable on boot (optional):${NC}"
echo "      sudo systemctl enable nginx-inspector"
echo ""
echo -e "   ${CYAN}4. Check status:${NC}"
echo "      sudo systemctl status nginx-inspector"
echo ""
echo -e "   ${CYAN}5. View logs:${NC}"
echo "      sudo journalctl -u nginx-inspector -f"
echo ""
echo -e "   ${CYAN}6. Access Web Dashboard:${NC}"
echo "      http://localhost:8080"
echo ""
echo -e "   ${CYAN}7. Test API (requires authentication):${NC}"
echo "      # Get API key from .env file"
echo "      API_KEY=\$(grep NGINX_INSPECTOR_API_KEY $INSTALL_DIR/.env | cut -d'=' -f2)"
echo "      curl -H \"X-API-Key: \$API_KEY\" http://localhost:8765/api/health"
echo ""
echo -e "${GREEN}📚 For more information:${NC}"
echo "   https://github.com/shuvo-halder/nginx-inspector"
echo "   See .env.example for detailed configuration options"
echo ""
echo -e "${YELLOW}⚠ Important Security Notes:${NC}"
echo "   ✓ API key has been securely generated"
echo "   ✓ Store .env file safely - DO NOT commit to git"
echo "   ✓ Change HOST to 0.0.0.0 only if you need remote access"
echo "   ✓ Use HTTPS in production (reverse proxy recommended)"
echo "   ✓ Restrict CORS_ORIGINS to your specific domains"
echo "   ✓ Set DEBUG=False in production"
echo "   ✓ Keep .env file permissions at 600"
echo "   ✓ Rotate API keys regularly"
echo ""
echo -e "${CYAN}To regenerate API key:${NC}"
echo "   python3 -c \"import secrets; print(secrets.token_hex(32))\""
echo "   Then update NGINX_INSPECTOR_API_KEY in .env"
echo ""

exit 0
