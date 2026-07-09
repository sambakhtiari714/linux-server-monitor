print_incident_report() {

    echo ""
    echo "========= INCIDENT ======="
    echo "Component      : $INCIDENT_COMPONENT"
    echo "Status         : $INCIDENT_STATUS"
    echo "Pattern State  : $INCIDENT_PATTERN_STATE"
    echo "Incident Score : $INCIDENT_SCORE"
    echo "Severity       : $INCIDENT_SEVERITY"

    case "$INCIDENT_PATTERN_STATE" in

        OK|WARNING|ERROR)

            echo "Log Level      : $INCIDENT_LOG_LEVEL"
            echo "Error Count    : $INCIDENT_ERROR_COUNT"
            echo "Warning Count  : $INCIDENT_WARNING_COUNT"
            echo "Failed Count   : $INCIDENT_FAILED_COUNT"
            echo "Timeout Count  : $INCIDENT_TIMEOUT_COUNT"

            if [ -n "$INCIDENT_MATCHED_LINES" ]
            then
                echo ""
                echo "Detected Issues:"
                echo "----------------"
                echo "$INCIDENT_MATCHED_LINES"
            fi
        ;;

        SERVICE_NOT_INSTALLED)

            echo "Service is not installed."
        ;;

        NO_LOGS_FOUND)

            echo "No logs available for analysis."
        ;;

        ACCESS_DENIED)

            echo "Permission denied while reading logs."
        ;;

        *)

            echo "Unknown pattern state."
        ;;

    esac

}
