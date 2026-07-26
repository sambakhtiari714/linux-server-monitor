normalize_logs() {

    LOG_DATA=$(echo "$LOG_DATA" | tr '[:upper:]' '[:lower:]')

}

detect_log_level() {

    if echo "$LOG_DATA" | grep -q "fatal"
    then
        LOG_LEVEL="FATAL"

    elif echo "$LOG_DATA" | grep -q "error"
    then
        LOG_LEVEL="ERROR"

    elif echo "$LOG_DATA" | grep -q "warning"
    then
        LOG_LEVEL="WARNING"

    else
        LOG_LEVEL="INFO"

    fi

}

extract_patterns() {

    LOG_DATA="$1"

    PATTERN_STATE="OK"
    PATTERN_ERROR_COUNT=0
    PATTERN_WARNING_COUNT=0
    PATTERN_FAILED_COUNT=0
    PATTERN_TIMEOUT_COUNT=0
    PATTERN_MATCHED_LINES=""
    PATTERN_CRITICAL_FOUND=false
    LOG_LEVEL=""

    # No logs
    if [ -z "$LOG_DATA" ]
    then
        PATTERN_STATE="NO_LOGS_FOUND"
        return
    fi

    # Special states
    if [ "$LOG_DATA" = "SERVICE_NOT_INSTALLED" ] ||
       [ "$LOG_DATA" = "ACCESS_DENIED" ]
    then
        PATTERN_STATE="$LOG_DATA"
        return
    fi

    normalize_logs
    detect_log_level

    PATTERN_ERROR_COUNT=$(echo "$LOG_DATA" | grep -ic "error")
    PATTERN_WARNING_COUNT=$(echo "$LOG_DATA" | grep -ic "warning")
    PATTERN_FAILED_COUNT=$(echo "$LOG_DATA" | grep -ic "failed")
    PATTERN_TIMEOUT_COUNT=$(echo "$LOG_DATA" | grep -ic "timeout")

    PATTERN_MATCHED_LINES=$(
        echo "$LOG_DATA" |
        grep -iE "error|failed|fatal|panic|timeout|permission denied|connection refused"
    )

    if echo "$LOG_DATA" | grep -qiE "kernel panic|out of memory|segmentation fault|filesystem corruption"
    then
        PATTERN_CRITICAL_FOUND=true
    fi

    if [ "$PATTERN_ERROR_COUNT" -gt 0 ] ||
       [ "$PATTERN_FAILED_COUNT" -gt 0 ] ||
       [ "$PATTERN_TIMEOUT_COUNT" -gt 0 ]
    then
        PATTERN_STATE="ERROR"

    elif [ "$PATTERN_WARNING_COUNT" -gt 0 ]
    then
        PATTERN_STATE="WARNING"

    fi

}
