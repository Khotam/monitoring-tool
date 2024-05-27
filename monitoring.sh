#!/bin/bash

script_folder=$(dirname $(readlink -f "$0"))
source ${script_folder}/conf.d/init.conf

init(){
	if [[ ! -d "$LOG_FILE_PATH" ]]; then 
		mkdir -p $LOG_FILE_PATH 
	fi
	if [[ ! -d "$STATE_FILES_PATH" ]]; then
	       	mkdir -p $STATE_FILES_PATH
	else
		rm -f ${STATE_FILES_PATH}/*
       	fi
	touch ${STATE_FILES_PATH}/running
}

source ${script_folder}/workers/calculate_load

#service variables
cpu_active_alert_count=0
ram_active_alert_count=0

init

while [[ -f ${STATE_FILES_PATH}/running ]]; do
	calculate_load \
                "⚡️ CPU" \
                $(awk "BEGIN {printf \"%d\", ($(uptime | awk '{ print $(NF-2) }' | tr -d ',' | tr -d '.'))}") \
                ${script_folder}/conf.d/cpu.conf

	calculate_load \
                "📶 RAM" \
                $(awk "BEGIN {printf \"%d\", ($(free --mega | awk 'NR==2 {print $3}'|bc) / $(free --mega | awk 'NR==2 {print $2}'|bc)) * 100}") \
                ${script_folder}/conf.d/ram.conf

	calculate_load \
		"💿 DISK" \
		$(df -h | awk 'NR==2 {print $5}' | tr -d /%/ | bc) \
		${script_folder}/conf.d/disk.conf

	sleep $MONITORING_INTERVAL
done


