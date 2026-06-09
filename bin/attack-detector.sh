#!/bin/bash
LOGFILE=$1

echo "SQL Injection Attempts:"
grep -Ei "union|select|drop|insert|or 1=1" $LOGFILE | wc -l

echo
echo "XSS Attempts:"
grep -Ei "<script>" $LOGFILE | wc -l

echo
echo "Directory Traversal:"
grep "../" $LOGFILE | wc -l

echo
echo "Scanner Tools:"
grep -Ei "nikto|sqlmap|nmap|acunetix" $LOGFILE | wc -l

echo
echo "Suspicious IPs (>200 requests)"
awk '{print $1}' $LOGFILE | sort | uniq -c | awk '$1>200' | sort -nr