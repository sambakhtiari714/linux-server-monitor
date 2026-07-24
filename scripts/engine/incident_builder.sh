build_incident() {

    INCIDENT_COMPONENT="$SERVICE"

    INCIDENT_STATUS="$STATUS"

    INCIDENT_PATTERN_STATE="$PATTERN_STATE"

    INCIDENT_LOG_LEVEL="$LOG_LEVEL"

    INCIDENT_SCORE="$INCIDENT_SCORE"

    INCIDENT_SEVERITY="$INCIDENT_SEVERITY"

    INCIDENT_TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

}
print_incident() {

    echo "Component      : $INCIDENT_COMPONENT"
    echo "Status         : $INCIDENT_STATUS"
    echo "Pattern State  : $INCIDENT_PATTERN_STATE"
    echo "Log Level      : $INCIDENT_LOG_LEVEL"
    echo "Incident Score : $INCIDENT_SCORE"
    echo "Severity       : $INCIDENT_SEVERITY"
    echo "Timestamp      : $INCIDENT_TIMESTAMP"

}
