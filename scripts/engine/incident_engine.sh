process_incidents() {

    for SERVICE in $SERVICES
    do

        STATUS_VAR="${SERVICE^^}_STATUS"
        STATUS="${!STATUS_VAR}"

        if [ "$STATUS" = "DOWN" ]
        then

            echo ""
            echo "========= INCIDENT ======="
            echo "Component      : $SERVICE"
            echo "Status         : $STATUS"

            LOG_RESULT=$(collect_service_logs "$SERVICE")

            extract_patterns "$LOG_RESULT"

            calculate_severity

            echo "Pattern State  : $PATTERN_STATE"

            if [ "$PATTERN_STATE" = "OK" ] || \
               [ "$PATTERN_STATE" = "WARNING" ] || \
               [ "$PATTERN_STATE" = "ERROR" ]
            then
                echo "Log Level      : $LOG_LEVEL"
            fi

            echo "Incident Score : $INCIDENT_SCORE"
            echo "Severity       : $INCIDENT_SEVERITY"

            case "$PATTERN_STATE" in

                OK)

                    echo "Error Count   : $PATTERN_ERROR_COUNT"
                    echo "Warning Count : $PATTERN_WARNING_COUNT"
                    echo "Failed Count  : $PATTERN_FAILED_COUNT"
                    echo "Timeout Count : $PATTERN_TIMEOUT_COUNT"

                    if [ -n "$PATTERN_MATCHED_LINES" ]
                    then
                        echo ""
                        echo "Detected Issues:"
                        echo "----------------"
                        echo "$PATTERN_MATCHED_LINES"
                    fi
                ;;

                WARNING)

                    echo "Error Count   : $PATTERN_ERROR_COUNT"
                    echo "Warning Count : $PATTERN_WARNING_COUNT"
                    echo "Failed Count  : $PATTERN_FAILED_COUNT"
                    echo "Timeout Count : $PATTERN_TIMEOUT_COUNT"

                    if [ -n "$PATTERN_MATCHED_LINES" ]
                    then
                        echo ""
                        echo "Detected Issues:"
                        echo "----------------"
                        echo "$PATTERN_MATCHED_LINES"
                    fi
                ;;

                ERROR)

                    echo "Error Count   : $PATTERN_ERROR_COUNT"
                    echo "Warning Count : $PATTERN_WARNING_COUNT"
                    echo "Failed Count  : $PATTERN_FAILED_COUNT"
                    echo "Timeout Count : $PATTERN_TIMEOUT_COUNT"

                    if [ -n "$PATTERN_MATCHED_LINES" ]
                    then
                        echo ""
                        echo "Detected Issues:"
                        echo "----------------"
                        echo "$PATTERN_MATCHED_LINES"
                    fi
                ;;

                NO_LOGS_FOUND)

                    echo "No logs available for analysis."
                ;;

                SERVICE_NOT_INSTALLED)

                    echo "Service is not installed."
                ;;

                ACCESS_DENIED)

                    echo "Permission denied while reading logs."
                ;;

                *)

                    echo "Unknown pattern state."
                ;;

            esac

        fi

    done

}
