#!/bin/bash
LOGFILE=$1

TOPIP=$(awk '{print $1}' $LOGFILE | sort | uniq -c | sort -nr | head -5)
TOPURL=$(awk '{print $7}' $LOGFILE | sort | uniq -c | sort -nr | head -5)
ERROR404=$(awk '$9==404' $LOGFILE | wc -l)

cat <<EOF
{
  "top_ips":"$TOPIP",
  "top_urls":"$TOPURL",
  "errors":{
     "404":$ERROR404
  }
}
EOF