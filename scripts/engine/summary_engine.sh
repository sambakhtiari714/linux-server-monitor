print_summary(){

    echo ""
    echo "======================================="
    echo "SERVER HEALTH SUMMARY"
    echo "======================================="

    echo "Disk    : $DISK_STATUS"
    echo "RAM     : $RAM_STATUS"
    echo "CPU     : $CPU_STATUS"

    echo "SSH     : $SSH_STATUS"
    echo "NGINX   : $NGINX_STATUS"
    echo "DOCKER  : $DOCKER_STATUS"
    echo ""
    echo ""
    if [ "$DISK_STATUS" = "OK" ] &&
	    [ "$RAM_STATUS" = "OK" ] &&
	    [ "$CPU_STATUS" = "OK" ] &&
	    [ "$SSH_STATUS" = "OK" ] &&
	    [ "$NGINX_STATUS" = "OK" ] &&
	    [ "$DOCKER_STATUS" = "OK" ]
	then
		OVERALL_STATUS="HEALTHY"
	else
		OVERALL_STATUS="WARNING"
    fi

    echo "Overall Status : $OVERALL_STATUS"

}


