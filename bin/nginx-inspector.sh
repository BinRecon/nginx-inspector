#!/bin/bash
LOGFILE="$1"
if [[ -z "$LOGFILE" ]]; then
  echo "Usage: nginx-inspector.sh <logfile>"
  exit 1
fi

while true
do
    clear
    echo -e "${CYAN}================ NGINX INSPECTOR =================${NC}"
    echo -e "${YELLOW}1)${NC} Top IP Analysis"
    echo -e "${YELLOW}2)${NC} Top URL Analysis"
    echo -e "${YELLOW}3)${NC} Status Code Analysis"
    echo -e "${YELLOW}4)${NC} Run Attack Detection"
    echo -e "${YELLOW}5)${NC} Real-time Monitor"
    echo -e "${YELLOW}6)${NC} Generate JSON Report"
    echo -e "${YELLOW}0)${NC} Exit"
    echo -e "${CYAN}===================================================${NC}"

    read -p "Enter option: " option

    case $option in
        1)
            echo -e "${BLUE}Running Top IP Analysis...${NC}"
            progress_bar 20
            awk '{print $1}' $1 | sort | uniq -c | sort -nr | head
            read -p "Press Enter to continue..."
            ;;
        2)
            echo -e "${BLUE}Running Top URL Analysis...${NC}"
            progress_bar 20
            awk '{print $7}' $1 | sort | uniq -c | sort -nr | head
            read -p "Press Enter to continue..."
            ;;
        3)
            echo -e "${BLUE}Running Status Code Analysis...${NC}"
            progress_bar 15
            awk '{print $9}' $1 | sort | uniq -c | sort -nr
            read -p "Press Enter to continue..."
            ;;
        4)
            echo -e "${RED}Running Attack Detection...${NC}"
            progress_bar 25
            bash attack-detector.sh $1
            read -p "Press Enter to continue..."
            ;;
        5)
            echo -e "${CYAN}Starting Real-time Monitor... Press CTRL+C to stop${NC}"
            bash realtime-monitor.sh $1
            ;;
        6)
            echo -e "${GREEN}Generating JSON Report...${NC}"
            progress_bar 10
            bash json-report.sh $1
            read -p "Press Enter to continue..."
            ;;
        0)
            echo -e "${YELLOW}Exiting...${NC}"
            exit
            ;;
        *)
            echo -e "${RED}Invalid Option!${NC}"
            read -p "Press Enter to continue..."
            ;;
    esac
done