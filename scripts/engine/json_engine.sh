init_incident_report() {
	SERVICES_JSON=()
}

add_service_to_report() {
	local NAME="$1"
	local SVC_STATUS="$2"
	local OBJ

	if [ "$SVC_STATUS" = "DOWN" ]
	then
		local MATCHED_JSON
		MATCHED_JSON=$(printf '%s' "$PATTERN_MATCHED_LINES" | jq -R -s 'split("\n") | map(select(length > 0))')

		local LOG_LEVEL_JSON
		if [ -z "$LOG_LEVEL" ]
		then
			LOG_LEVEL_JSON="null"
		else
			LOG_LEVEL_JSON=$(jq -n --arg v "$LOG_LEVEL" '$v')
		fi

		OBJ=$(jq -n \
			--arg name "$NAME" \
			--arg status "DOWN" \
			--arg severity "$INCIDENT_SEVERITY" \
			--argjson critical_pattern_matched "$PATTERN_CRITICAL_FOUND" \
			--argjson score "$INCIDENT_SCORE" \
			--arg pattern_state "$PATTERN_STATE" \
			--argjson log_level "$LOG_LEVEL_JSON" \
			--argjson error_count "$PATTERN_ERROR_COUNT" \
			--argjson warning_count "$PATTERN_WARNING_COUNT" \
			--argjson failed_count "$PATTERN_FAILED_COUNT" \
			--argjson timeout_count "$PATTERN_TIMEOUT_COUNT" \
			--argjson matched_lines "$MATCHED_JSON" \
			'{
				name: $name,
				status: $status,
				severity: $severity,
				critical_pattern_matched: $critical_pattern_matched,
				score: $score,
				pattern_state: $pattern_state,
				log_level: $log_level,
				error_count: $error_count,
				warning_count: $warning_count,
				failed_count: $failed_count,
				timeout_count: $timeout_count,
				matched_lines: $matched_lines
			}')
	else
		OBJ=$(jq -n \
			--arg name "$NAME" \
			'{
				name: $name,
				status: "OK",
				severity: "OK",
				critical_pattern_matched: false,
				score: null,
				pattern_state: null,
				log_level: null,
				error_count: null,
				warning_count: null,
				failed_count: null,
				timeout_count: null,
				matched_lines: []
			}')
	fi

	SERVICES_JSON+=("$OBJ")
}

write_incident_report() {
	local SERVICES_ARRAY_JSON
	SERVICES_ARRAY_JSON=$(printf '%s\n' "${SERVICES_JSON[@]}" | jq -s '.')

	local OVERALL_JSON
	if [ "$OVERALL_STATUS" = "HEALTHY" ]
	then
		OVERALL_JSON="HEALTHY"
	else
		OVERALL_JSON="WARNING"
	fi

	mkdir -p output

	jq -n \
		--arg generated_at "$(date -Iseconds)" \
		--arg hostname "$(hostname)" \
		--arg overall_status "$OVERALL_JSON" \
		--argjson disk_usage "$DISK_USAGE" \
		--arg disk_status "$DISK_STATUS" \
		--arg disk_severity "$DISK_SEVERITY" \
		--argjson ram_usage "$RAM_USAGE" \
		--arg ram_status "$RAM_STATUS" \
		--arg ram_severity "$RAM_SEVERITY" \
		--argjson cpu_usage "$CPU_USAGE_INT" \
		--arg cpu_status "$CPU_STATUS" \
		--arg cpu_severity "$CPU_SEVERITY" \
		--argjson services "$SERVICES_ARRAY_JSON" \
		'{
			generated_at: $generated_at,
			hostname: $hostname,
			overall_status: $overall_status,
			system: {
				disk: {usage_percent: $disk_usage, status: $disk_status, severity: $disk_severity},
				ram: {usage_percent: $ram_usage, status: $ram_status, severity: $ram_severity},
				cpu: {usage_percent: $cpu_usage, status: $cpu_status, severity: $cpu_severity}
			},
			services: $services
		}' > output/incidents.json
}