#!/bin/bash
source scripts/engine/summary_engine.sh
source scripts/collectors/services.sh
source scripts/collectors/disk.sh
source scripts/engine/config_validator.sh
source config/config.conf
validate_config
source scripts/collectors/ram.sh
source scripts/collectors/cpu.sh
source scripts/engine/policy_engine.sh
source scripts/engine/log_engine.sh
source scripts/engine/incident_engine.sh
source scripts/engine/pattern_engine.sh
source scripts/engine/severity_engine.sh
source scripts/engine/incident_builder.sh
source scripts/engine/json_engine.sh
source scripts/engine/report_engine.sh
EXIT_CODE=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
YELLOW='\033[1;33m'

mkdir -p logs
exec > >(tee -a logs/system.log) 2>&1

echo "======================================="
echo "report date: $(date)"

echo "host name"
hostname
echo ""
echo "current user"
whoami
echo ""
echo "uptime"
uptime
echo ""
echo "disk usage"
df -h
echo ""
echo "memory usage"
free -h

echo ""

check_disk
check_ram
check_cpu

echo ""

init_incident_report
check_services
process_incidents
print_summary
write_incident_report

echo "Final Exit Code = $EXIT_CODE"
exit $EXIT_CODE