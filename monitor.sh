#!/bin/bash
EXIT_CODE=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'

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

mkdir -p logs
{

	echo "======================================="
	echo "report date: $(date)"
	
	echo "host name"
	hostname
	echo""
	echo "current user"
	whoami
	echo""
	echo "uptime"
	uptime
	echo""
	echo "disk usage"
	df -h
	echo ""
	echo "memory usage"
	free -h
	
	echo""
	DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
	echo "current Disk Usage: ${DISK_USAGE}%"


	if [ "$DISK_USAGE" -gt 80 ]
	then
		echo -e "${RED}WARNING: Disk usage is above 80%${NC}"
		EXIT_CODE=1
	else
		echo -e "${GREEN}Disk usage is normal${NC}"
	fi
	TOTAL_RAM=$(free | grep Mem | awk '{print $2}')
	USED_RAM=$(free | grep Mem | awk '{print $3}')
	RAM_USAGE=$(( USED_RAM *100 / TOTAL_RAM ))
	echo "RAM USAGE : ${RAM_USAGE}%"
	if [ "$RAM_USAGE" -gt 85 ]
	then
		echo -e "${RED}WARNING: RAM Usage is above 85%${NC}"
		EXIT_CODE=1
	else
		echo -e "${GREEN}RAM Usage is normal${NC}"
	fi
	check_service ssh
	check_service nginx
	check_service docker


} | tee -a logs/system.log
echo "Final Exit Code = $EXIT_CODE"
exit $EXIT_CODE
