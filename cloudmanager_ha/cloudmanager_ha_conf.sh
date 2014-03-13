#!/bin/bash
#
# create configuration
#
# for example:
# /etc/my.cnf
# /etc/keepalived/keepalived.conf
# /opt/cloudmanager/server/webapps/client/WEB-INF/classes/db.properties
#
# the process of recover is delete the configuration of mysql/keepfalived/cloudmanager
#

cur_path=$(cd `dirname $0`; pwd)
. $cur_path/logger.sh

create_cloudmanager_ha_conf()
{
	#Check the parameter
	if [ $# != 4 ];then
		logger error "need four parameter,please check it out!"
		logger info "usage: $0 create {MASTER|BACKUP} {MASTERIP}{BACKUPIP} {VIP}"
		exit 1
	fi

	#Check whether install keepalived
	keepalived_locate=`find / -name keepalived`
	if [[ "$keepalived_locate" == "" ]];then
		logger error "keepalived is not installed,please install keepalived first!"
	    exit 1
    fi

	if [[ $1 == "MASTER" ]];then
		sh $cur_path/create_mysql_conf.sh create $1
		sh $cur_path/create_keepalived_conf.sh create $1 $2 $3 $4
		sh $cur_path/create_cloudmanager_conf.sh create $2 $3
	elif [[ $1 == "BACKUP" ]];then
		sh $cur_path/create_mysql_conf.sh create $1
		sh $cur_path/create_keepalived_conf.sh create $1 $2 $3 $4
		sh $cur_path/create_cloudmanager_conf.sh create $2 $3
	fi
}


create_realserver_ha_conf()
{
	if [ $# != 1 ];then
		logger error "realserver need one parameter,please check it out!"
		logger error "usage: $0 create {VIP}"
		exit 1
	fi


    vip=$1
	realserver_path=$cur_path/script
	realserver_conf=realserver.sh
	realserver_conf_bak=realserver.sh.bak
	realserver_conf_path=/etc/rc.d/init.d

	if [[ ! -d $realserver_path ]];then
		logger error "the path of realserver is not exit!"
		exit 1
	fi

	cd $realserver_path
	\cp $realserver_path/$realserver_conf $realserver_path/$realserver_conf_bak
	sed -i "s/VIP_value/$vip/g" $realserver_path/$realserver_conf_bak

    \mv $realserver_path/$realserver_conf_bak $realserver_conf_path/$realserver_conf


}

recover_cloudmanager_ha_conf()
{
	sh $cur_path/create_mysql_conf.sh recover
	sh $cur_path/create_keepalived_conf.sh recover
	sh $cur_path/create_cloudmanager_conf.sh recover
	if [[ $? -eq 0 ]];then
		logger debug "the conf of keepalived and mysql and cloudmanager has been recovered!"
	else
		logger debug "the process of conf is error,please check out!"
	fi
    
}

case $1 in
	create)
	create_cloudmanager_ha_conf $2 $3 $4 $5
	create_realserver_ha_conf $5
	;;
	recover)
	recover_cloudmanager_ha_conf
	;;
	*)
	logger error "usage: $0 {create | recover}"
	exit 1
	;;
esac
