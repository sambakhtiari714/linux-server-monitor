#!/bin/bash
source scripts/summary.sh
source scripts/check_services.sh
source scripts/check_disk.sh
source config.conf
source scripts/check_ram.sh
EXIT_CODE=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'


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

echo ""
echo "CPU INFORMATION"

CPU_CORES=$(nproc)

echo "CPU Cores : $CPU_CORES"

LOAD=$( cat /proc/loadavg | awk '{print $1, $2, $3}')

echo "Load Average : $LOAD"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100-$8}')
echo "Cpu Usage : ${CPU_USAGE}%"


CPU_USAGE_INT=$(printf "%.0f" "$CPU_USAGE")

if [ "$CPU_USAGE_INT" -gt 85 ]
then
	echo -e "${RED}WARNING: CPU Usage is above 85%${NC}"
	CPU_STATUS="WARNING"
	EXIT_CODE=1
else
	echo -e "${GREEN}Cpu Usage is normal ${NC}"
	CPU_STATUS="OK"
fi

	check_services
	print_summary


} | tee -a logs/system.log
echo "Final Exit Code = $EXIT_CODE"
exit $EXIT_CODE
