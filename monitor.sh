#!/bin/bash
source scripts/engine/summary_engine.sh
source scripts/collectors/services.sh
source scripts/collectors/disk.sh
source config/config.conf
source scripts/collectors/ram.sh
source scripts/collectors/cpu.sh
source scripts/engine/policy_engine.sh
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
	check_cpu

echo ""

	check_services
	print_summary
	


} | tee -a logs/system.log
echo "Final Exit Code = $EXIT_CODE"
exit $EXIT_CODE
