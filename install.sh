#!/bin/bash

# Nginx Inspector Installation Script
# This script installs nginx-inspector and all its dependencies

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

if ! command -v python3 -m venv &> /dev/null; then
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

if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    cp "$SCRIPT_DIR/requirements.txt" "$INSTALL_DIR/" || error_exit "Failed to copy requirements.txt"
fi

if [ -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env" "$INSTALL_DIR/" || error_exit "Failed to copy .env"
fi

success_msg "Application files copied"
echo ""

# Step 4: Setup permissions
info_msg "Setting up permissions..."

chmod 755 "$INSTALL_DIR" || error_exit "Failed to set directory permissions"
chmod +x "$INSTALL_DIR/bin/nginx-inspector" || error_exit "Failed to set nginx-inspector permissions"
chmod +x "$INSTALL_DIR/bin"/*.sh 2>/dev/null || true

success_msg "Permissions set correctly"
echo ""

# Step 5: Create symbolic link
info_msg "Creating command-line interface..."

# Remove old symlink if it exists
if [ -L "/usr/local/bin/nginx-inspector" ]; then
    rm "/usr/local/bin/nginx-inspector"
fi

ln -s "$INSTALL_DIR/bin/nginx-inspector" "/usr/local/bin/nginx-inspector" || error_exit "Failed to create symlink"
success_msg "Command 'nginx-inspector' is now available globally"
echo ""

# Step 6: Create Python virtual environment
info_msg "Setting up Python virtual environment..."

if [ -d "$VENV_DIR" ]; then
    rm -rf "$VENV_DIR"
fi

python3 -m venv "$VENV_DIR" || error_exit "Failed to create virtual environment"
success_msg "Virtual environment created"
echo ""

# Step 7: Install Python dependencies
info_msg "Installing Python dependencies..."

if [ ! -f "$INSTALL_DIR/requirements.txt" ]; then
    error_exit "requirements.txt not found at $INSTALL_DIR/requirements.txt"
fi

"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel > /dev/null 2>&1
if "$VENV_DIR/bin/pip" install -r "$INSTALL_DIR/requirements.txt" > /dev/null 2>&1; then
    success_msg "Python dependencies installed successfully"
else
    error_exit "Failed to install Python dependencies"
fi
echo ""

# Step 8: Setup systemd service
info_msg "Setting up systemd service..."

if [ -f "$SCRIPT_DIR/service/nginx-inspector.service" ]; then
    cp "$SCRIPT_DIR/service/nginx-inspector.service" "/etc/systemd/system/" || error_exit "Failed to copy service file"
    
    # Update paths in service file if needed
    sed -i "s|/usr/local/nginx-inspector|$INSTALL_DIR|g" "/etc/systemd/system/nginx-inspector.service"
    
    systemctl daemon-reload || error_exit "Failed to reload systemd daemon"
    systemctl enable nginx-inspector > /dev/null 2>&1 || error_exit "Failed to enable service"
    
    success_msg "Systemd service configured"
else
    warning_msg "Service file not found, skipping systemd setup"
fi
echo ""

# Step 9: Verify installation
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

success_msg "Installation verified successfully"
echo ""

# Step 10: Display installation summary
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║    Installation Complete! ✓           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📦 Installation Directory:${NC}"
echo "   $INSTALL_DIR"
echo ""
echo -e "${GREEN}🚀 Getting Started:${NC}"
echo ""
echo -e "   ${CYAN}1. View status:${NC}"
echo "      nginx-inspector status"
echo ""
echo -e "   ${CYAN}2. Start service:${NC}"
echo "      nginx-inspector start"
echo ""
echo -e "   ${CYAN}3. Access Web Dashboard:${NC}"
echo "      http://localhost:8080"
echo ""
echo -e "   ${CYAN}4. Access API:${NC}"
echo "      http://localhost:8765/api"
echo ""
echo -e "   ${CYAN}5. View help:${NC}"
echo "      nginx-inspector help"
echo ""
echo -e "${GREEN}📚 For more information:${NC}"
echo "   https://github.com/shuvo-halder/nginx-inspector"
echo ""
echo -e "${YELLOW}⚠ Important:${NC}"
echo "   - Edit .env file for configuration"
echo "   - Check logs: sudo journalctl -u nginx-inspector -f"
echo "   - Restart after config changes: nginx-inspector restart"
echo ""

exit 0
