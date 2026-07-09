calculate_incident_score() {

    INCIDENT_SCORE=0

    INCIDENT_SCORE=$(( \
        PATTERN_ERROR_COUNT * 3 + \
        PATTERN_FAILED_COUNT * 2 + \
        PATTERN_TIMEOUT_COUNT * 4 + \
        PATTERN_WARNING_COUNT * 1 \
    ))

}


calculate_severity() {

    calculate_incident_score

    INCIDENT_SEVERITY="LOW"

    case "$PATTERN_STATE" in

        SERVICE_NOT_INSTALLED)
            INCIDENT_SEVERITY="LOW"
        ;;

        NO_LOGS_FOUND)
            INCIDENT_SEVERITY="LOW"
        ;;

        ACCESS_DENIED)
            INCIDENT_SEVERITY="MEDIUM"
        ;;

        WARNING)
            INCIDENT_SEVERITY="MEDIUM"
        ;;

        ERROR)

            if [ "$INCIDENT_SCORE" -le 5 ]
            then
                INCIDENT_SEVERITY="LOW"

            elif [ "$INCIDENT_SCORE" -le 12 ]
            then
                INCIDENT_SEVERITY="MEDIUM"

            elif [ "$INCIDENT_SCORE" -le 20 ]
            then
                INCIDENT_SEVERITY="HIGH"

            else
                INCIDENT_SEVERITY="CRITICAL"

            fi
        ;;

        *)
            INCIDENT_SEVERITY="LOW"
        ;;

    esac

}
