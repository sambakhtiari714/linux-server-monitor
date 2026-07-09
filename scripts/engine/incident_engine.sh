process_incidents() {

    for SERVICE in $SERVICES
    do

        STATUS_VAR="${SERVICE^^}_STATUS"
        STATUS="${!STATUS_VAR}"

        if [ "$STATUS" = "DOWN" ]
        then

            LOG_RESULT=$(collect_service_logs "$SERVICE")

            extract_patterns "$LOG_RESULT"

            calculate_severity

            build_incident

            print_incident_report

        fi

    done

}
