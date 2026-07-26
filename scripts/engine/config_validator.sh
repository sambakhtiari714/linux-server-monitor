validate_config() {
	local errors=0

	for var in DISK_WARNING_THRESHOLD DISK_CRITICAL_THRESHOLD \
	           RAM_WARNING_THRESHOLD RAM_CRITICAL_THRESHOLD \
	           CPU_WARNING_THRESHOLD CPU_CRITICAL_THRESHOLD
	do
		if ! [[ "${!var}" =~ ^[0-9]+$ ]]
		then
			echo "config error: $var must be a number, got '${!var}'"
			errors=1
		fi
	done

	if [ "$errors" -eq 0 ]
	then
		[ "$DISK_WARNING_THRESHOLD" -lt "$DISK_CRITICAL_THRESHOLD" ] || { echo "config error: DISK_WARNING_THRESHOLD must be less than DISK_CRITICAL_THRESHOLD"; errors=1; }
		[ "$RAM_WARNING_THRESHOLD"  -lt "$RAM_CRITICAL_THRESHOLD"  ] || { echo "config error: RAM_WARNING_THRESHOLD must be less than RAM_CRITICAL_THRESHOLD";  errors=1; }
		[ "$CPU_WARNING_THRESHOLD"  -lt "$CPU_CRITICAL_THRESHOLD"  ] || { echo "config error: CPU_WARNING_THRESHOLD must be less than CPU_CRITICAL_THRESHOLD";  errors=1; }
	fi

	if [ -z "$SERVICES" ]
	then
		echo "config error: SERVICES is empty"
		errors=1
	fi

	if [ "$errors" -eq 1 ]
	then
		echo "Invalid config.conf — aborting."
		exit 2
	fi
}
