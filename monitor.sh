#!/bin/bash
source scripts/check_disk.sh
source config.conf
source scripts/check_ram.sh
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

	check_disk
	check_ram
	check_service ssh
	check_service nginx
	check_service docker


} | tee -a logs/system.log
echo "Final Exit Code = $EXIT_CODE"
exit $EXIT_CODE
