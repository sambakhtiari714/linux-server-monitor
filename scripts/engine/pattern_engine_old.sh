normalize_logs() {

    LOG_DATA=$(echo "$LOG_DATA" | tr '[:upper:]' '[:lower:]')

}
extract_patterns() {

    LOG_DATA="$1"

    PATTERN_STATE="OK"

    normalize_logs

    PATTERN_ERROR_COUNT=0
    PATTERN_WARNING_COUNT=0
    PATTERN_FAILED_COUNT=0
    PATTERN_TIMEOUT_COUNT=0

    PATTERN_MATCHED_LINES=""
    PATTERN_KEYWORDS=""

    if [ "$LOG_DATA" = "SERVICE_NOT_INSTALLED" ] ||
       [ "$LOG_DATA" = "NO_LOGS_FOUND" ] ||
       [ "$LOG_DATA" = "ACCESS_DENIED" ]
    then
        PATTERN_STATE="$LOG_DATA"
        return
    fi

    PATTERN_ERROR_COUNT=$(echo "$LOG_DATA" | grep -c "error")
    PATTERN_WARNING_COUNT=$(echo "$LOG_DATA" | grep -c "warning")
    PATTERN_FAILED_COUNT=$(echo "$LOG_DATA" | grep -c "failed")
    PATTERN_TIMEOUT_COUNT=$(echo "$LOG_DATA" | grep -c "timeout")

    PATTERN_MATCHED_LINES=$(
        echo "$LOG_DATA" |
        grep -E "error|failed|fatal|panic|timeout|permission denied|connection refused"
    )

}
