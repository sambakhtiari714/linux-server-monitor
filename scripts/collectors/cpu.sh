check_cpu() {

    echo ""
    echo "CPU INFORMATION"

    CPU_CORES=$(nproc)
    echo "CPU Cores : $CPU_CORES"

    LOAD=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo "Load Average : $LOAD"

    CPU_USAGE=$(top -bn1 | awk -F'id,' '/Cpu\(s\)/ {split($1,a,","); print 100-a[length(a)]}')

    echo "Cpu Usage : ${CPU_USAGE}%"
    CPU_USAGE_INT=$(printf "%.0f" "$CPU_USAGE")
    evaluate_metric \
	    CPU \
	    "$CPU_USAGE_INT" \
	    "$CPU_WARNING_THRESHOLD" \
	    "$CPU_CRITICAL_THRESHOLD"
}
