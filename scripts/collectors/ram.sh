check_ram() {

    TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
    USED_RAM=$(free | grep Mem | awk '{print $3}')

    RAM_USAGE=$(( USED_RAM *100 / TOTAL_RAM ))

    echo "RAM USAGE : ${RAM_USAGE}%"
    evaluate_metric \
	    RAM \
	    "$RAM_USAGE" \
	    "$RAM_WARNING_THRESHOLD" \
	    "$RAM_CRITICAL_THRESHOLD"
}
