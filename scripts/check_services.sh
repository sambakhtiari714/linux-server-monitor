
check_service(){
    SERVICE_NAME=$1

    STATUS=$(systemctl is-active "$SERVICE_NAME")
    if [ "$STATUS" != "active" ]
    then
        echo -e "${RED}Warning: $SERVICE_NAME service is down${NC}"
        EXIT_CODE=1
    else
        echo -e "${GREEN}$SERVICE_NAME service is running${NC}"
    fi
}
check_services(){
	check_service ssh
	check_service nginx
	check_service docker
}

