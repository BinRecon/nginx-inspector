#!/bin/bash
LOGFILE=$1

echo "Real-time monitoring started... Press CTRL+C to stop"

tail -F $LOGFILE | while read line
do
  IP=$(echo $line | awk '{print $1}')
  URL=$(echo $line | awk '{print $7}')
  STATUS=$(echo $line | awk '{print $9}')
  echo "[REQUEST] $IP -> $URL ($STATUS)"
done