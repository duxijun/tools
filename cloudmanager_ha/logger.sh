#!/bin/bash

function logger()
{
    if [ $1 = "debug" ] || [ $1 = "info" ] || [ $1 = "warn" ] || [ $1 = "error" ]
	then
		level=`echo $1 | tr '[:lower:]' '[:upper:]'`
	else
		echo "logger parameter is error. please check logger"
		exit 1
	fi
    now_time=$(date +"%Y-%m-%d %H:%M:%S")
	file=`basename $0`
	linenum=`caller 0 | awk '{print$1}'`
	echo ${now_time} $file ${FUNCNAME[1]}:${linenum} \[${level}\] $2  | tee -a ${log_file}
}


log_file='/var/log/cloud/cloudmanager_ha.log'
#logger info '####################################################'
#logger info 'The log is writed to '${log_file}
#logger info '#####################################################'


function trim()
{
	 echo "$1" | grep -o "[^ ]\+\( \+[^ ]\+\)*"
}


