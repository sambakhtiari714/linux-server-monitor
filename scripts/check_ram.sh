check_ram() {

    TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
    USED_RAM=$(free | grep Mem | awk '{print $3}')

    RAM_USAGE=$(( USED_RAM *100 / TOTAL_RAM ))

    echo "RAM USAGE : ${RAM_USAGE}%"

    if [ "$RAM_USAGE" -gt "$RAM_THRESHOLD" ]
    then
        echo -e "${RED}WARNING: RAM Usage is above ${RAM_THRESHOLD}%${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}RAM Usage is normal${NC}"
    fi
}
