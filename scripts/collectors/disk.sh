check_disk() {

    DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    echo "current Disk Usage: ${DISK_USAGE}%"

    evaluate_metric \
        DISK \
        "$DISK_USAGE" \
        "$DISK_WARNING_THRESHOLD" \
        "$DISK_CRITICAL_THRESHOLD"

}

