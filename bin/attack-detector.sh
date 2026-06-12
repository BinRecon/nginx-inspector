#!/bin/bash

# Nginx Inspector - Attack Detector
# FIX #1: Added proper input validation and quoting

# Validate input
if [ $# -eq 0 ]; then
    echo "Usage: $0 <logfile>"
    echo "Error: Log file path is required"
    exit 1
fi

LOGFILE="$1"

# FIX #2: Input validation - check if file exists and is readable
if [ ! -f "$LOGFILE" ]; then
    echo "Error: Log file not found: $LOGFILE"
    exit 1
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: Permission denied reading log file: $LOGFILE"
    exit 1
fi

# FIX #3: Prevent path traversal
if [[ "$LOGFILE" == *".."* ]]; then
    echo "Error: Invalid log file path - path traversal detected"
    exit 1
fi

# FIX #4: Proper quoting around variables throughout the script
echo "=== Security Threat Detection Report ==="
echo "Log File: $LOGFILE"
echo "Analysis Date: $(date)"
echo ""

echo "SQL Injection Attempts:"
grep -Ei "union|select|drop|insert|or 1=1" "$LOGFILE" | wc -l

echo ""
echo "XSS (Cross-Site Scripting) Attempts:"
grep -Ei "<script>" "$LOGFILE" | wc -l

echo ""
echo "Directory Traversal Attempts:"
grep -F "../" "$LOGFILE" | wc -l

echo ""
echo "Scanner Tools Detected:"
grep -Ei "nikto|sqlmap|nmap|acunetix" "$LOGFILE" | wc -l

echo ""
echo "Suspicious IPs (>200 requests)"
awk '{print $1}' "$LOGFILE" | sort | uniq -c | awk '$1>200' | sort -nr

echo ""
echo "=== End of Report ==="
