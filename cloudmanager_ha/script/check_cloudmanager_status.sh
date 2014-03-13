#!/bin/bash
cur_path=$(cd `dirname $0`; pwd)

now_time=$(date +"%Y-%m-%d %H:%M:%S")
chk_cloudmanager_status()
{
    cloudmanager_status=`/etc/init.d/cloudmanager status | awk '{print $3}' | awk -F . '{print $1}'`
    if [[ $cloudmanager_status == "running" ]];then
		exit 0
    elif [[ $cloudmanager_status == "stopped" ]];then
		sleep 30
        cloud_status=`/etc/init.d/cloudmanager status | awk '{print $3}' | awk -F . '{print $1}'`
        if [[ $cloud_status == "stopped" ]];then
		    echo $now_time "the programe of cloudmanager has been stop,so need to stop keepalived and swich to the standby!" >>/root/ha.log
            /etc/rc.d/init.d/realserver.sh stop >/dev/null 2>&1
            /etc/rc.d/init.d/keepalived stop >/dev/null 2>&1
        else 
            echo $now_time "the programe of cloudmanager is running." >>/root/ha.log
        fi
     fi
 }

pid_file="/var/run/mysqld/mysqld.pid"
if [[ -f "$pid_file" ]];then
	chk_cloudmanager_status
else
	sleep 30
	/etc/init.d/mysqld start
	pid_mysql_file="/var/run/mysqld/mysqld.pid"
	if [[ ! -f "$pid_mysql_file" ]];then
		chk_cloudmanager_status
	fi
fi


