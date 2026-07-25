#!/bin/bash

evaluate_metric() {

    METRIC=$1
    VALUE=$2
    WARNING=$3
    CRITICAL=$4

    if [ "$VALUE" -ge "$CRITICAL" ]
    then
        printf -v "${METRIC}_STATUS" "%s" "CRITICAL"
        printf -v "${METRIC}_SEVERITY" "%s" "CRITICAL"
        printf -v "${METRIC}_PENALTY" "%s" "25"

    elif [ "$VALUE" -ge "$WARNING" ]
    then
        printf -v "${METRIC}_STATUS" "%s" "WARNING"
        printf -v "${METRIC}_SEVERITY" "%s" "MEDIUM"
        printf -v "${METRIC}_PENALTY" "%s" "10"

    else
        printf -v "${METRIC}_STATUS" "%s" "OK"
        printf -v "${METRIC}_SEVERITY" "%s" "OK"
        printf -v "${METRIC}_PENALTY" "%s" "0"

    fi
}