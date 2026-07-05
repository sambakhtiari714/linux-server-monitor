check_disk() {

    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "current Disk Usage: ${DISK_USAGE}%"

    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]
    then
        echo -e "${RED}WARNING: Disk usage is above ${DISK_THRESHOLD}%${NC}"
        DISK_STATUS="WARNING"
        EXIT_CODE=1
    else
        echo -e "${GREEN}Disk usage is normal${NC}"
        DISK_STATUS="OK"
    fi
}
