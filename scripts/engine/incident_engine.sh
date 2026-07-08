process_incidents() {
	for SERVICE in $SERVICES
	do
		STATUS_VAR="${SERVICE^^}_STATUS"
		STATUS="${!STATUS_VAR}"

		if [ "$STATUS" = "DOWN" ]
		then
			echo ""
			echo "========= INCIDENT======="
			echo "Component : $SERVICE"
			echo "Status    : $STATUS"
			LOG_RESULT=$(collect_service_logs "$SERVICE")
			extract_patterns "$LOG_RESULT"
			if [ "$PATTERN_STATE" != "OK" ]
			then
			       	echo "Pattern State : $PATTERN_STATE"
			else
			       	echo "Pattern State : $PATTERN_STATE"
			       	echo "Error Count   : $PATTERN_ERROR_COUNT"
			       	echo "Warning Count : $PATTERN_WARNING_COUNT"
			       	echo "Failed Count  : $PATTERN_FAILED_COUNT"
			       	echo "Timeout Count : $PATTERN_TIMEOUT_COUNT"
			fi
			if [ -n "$PATTERN_MATCHED_LINES" ]
			then
				echo ""
				echo "Detected Issues:"
				echo "----------------"
				echo "$PATTERN_MATCHED_LINES"
			fi
		fi
	done

}
