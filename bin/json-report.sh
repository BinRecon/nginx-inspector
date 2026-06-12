#!/bin/bash

# Nginx Inspector - JSON Report Generator
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

# FIX #4: Proper quoting around variables
TOPIP=$(awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -5)
TOPURL=$(awk '{print $7}' "$LOGFILE" | sort | uniq -c | sort -nr | head -5)
ERROR404=$(awk '$9==404' "$LOGFILE" | wc -l)

# FIX #5: Proper JSON escaping for output
cat <<'EOF'
{
  "top_ips":"TOPIP_PLACEHOLDER",
  "top_urls":"TOPURL_PLACEHOLDER",
  "errors":{
     "404":ERROR404_PLACEHOLDER
  }
}
EOF
) | sed "s|TOPIP_PLACEHOLDER|$(echo "$TOPIP" | tr '\n' ';' | sed 's/;$//')|g" | sed "s|TOPURL_PLACEHOLDER|$(echo "$TOPURL" | tr '\n' ';' | sed 's/;$//')|g" | sed "s|ERROR404_PLACEHOLDER|$ERROR404|g"
