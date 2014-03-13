#!/bin/bash
cur_path=$(cd `dirname $0`; pwd)
. $cur_path/logger.sh

create_cloudmanager_conf()
{
	#Test function parameters
	if [ $# != 2 ];then
		logger error "the parametre of cloudmanager is error."
		logger error "usage: $0 create {MASTERIP}{SLAVEIP}"
		exit 1
	fi

	#Initialize the parameter
	cloudmanager_path=$cur_path/conf
	cloudmanager_conf_path=/opt/cloudmanager/server/webapps/client/WEB-INF/classes/
	cloudmanager_conf=db.properties
	cloudmanager_conf_bak=db.properties.bak 

	master_ip=$1
	host_ip=`ifconfig cloudbr0 | grep "inet addr" | cut -f 2 -d ':' | cut -f 1 -d ' '`
	slave_ip=$2

	#Modify the configuration of cloudmanager
	\cp $cloudmanager_path/$cloudmanager_conf $cloudmanager_path/$cloudmanager_conf_bak
	
	sed -i "s/HOST_IP/$host_ip/g" $cloudmanager_path/$cloudmanager_conf_bak
	sed -i "s/MYSQL_MASTER_IP/$master_ip/g" $cloudmanager_path/$cloudmanager_conf_bak
	sed -i "s/db.ha.enabled=false/db.ha.enabled=true/g" $cloudmanager_path/$cloudmanager_conf_bak
    sed -i "s/MYSQL_SLAVE_IP/$slave_ip/g" $cloudmanager_path/$cloudmanager_conf_bak

	#Move to cloudmanager_conf_path
	\mv $cloudmanager_path/$cloudmanager_conf_bak $cloudmanager_conf_path/$cloudmanager_conf
}
recover_cloudmanager_conf()
{
	#Initialize the parameter
	default_ip=127.0.0.1
	cloudmanager_path=$cur_path/conf
	cloudmanager_conf_path=/opt/cloudmanager/server/webapps/client/WEB-INF/classes/
	cloudmanager_conf=db.properties
	cloudmanager_conf_bak=db.properties.bak
	
	#Modify the configuration of cloudmanager
	\cp  $cloudmanager_path/$cloudmanager_conf $cloudmanager_path/$cloudmanager_conf_bak

	sed -i "s/HOST_IP/$default_ip/g" $cloudmanager_path/$cloudmanager_conf_bak
	sed -i "s/MYSQL_MASTER_IP/$default_ip/g" $cloudmanager_path/$cloudmanager_conf_bak
	sed -i "s/db.ha.enabled=true/db.ha.enabled=false/g" $cloudmanager_path/$cloudmanager_conf_bak
	sed -i "s/MYSQL_SLAVE_IP/$default_ip/g" $cloudmanager_path/$cloudmanager_conf_bak

	#Move to cloudmanager_conf_path
	\mv $cloudmanager_path/$cloudmanager_conf_bak $cloudmanager_conf_path/$cloudmanager_conf
}

case $1 in
	create)
	create_cloudmanager_conf $2 $3
	;;
	recover)
	recover_cloudmanager_conf
	;;
	*)
	logger error "usage: $0 {create | recover}"
	exit 1
	;;
esac
