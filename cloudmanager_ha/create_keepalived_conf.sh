#!/bin/bash
#
#create the configuration of keepalive
#recover the keepalive
#

cur_path=$(cd `dirname $0`; pwd)
. $cur_path/logger.sh

create_keepalived_conf()
{
	#Test function parameters
	if [[ $# != 4 ]];then
		logger error "the parameter of keepalived is error,please check log in details!"
		logger error "usage: $0 create {MASTER|BACKUP} {MASTERIP} {BACKUPIP} {VIP}"
		exit 1
	fi

	#Initialize the parametre
	conf_path=$cur_path/conf
    keepalive_conf=keepalived.conf
	keepalive_conf_bak=keepalived.conf.bak
	keepalive_conf_path=/etc/keepalived
	script_path=$cur_path/script
	notify_file=notify.sh
	notify_file_bak=notify.sh.bak

	status=$1
	master_ip=$2
	slave_ip=$3
	vip=$4
	
	#make the path of keepalived
	if [[ ! -d $keepalive_conf_path ]];then
		mkdir -p $keepalive_conf_path
 		logger info "create the path of /etc/keepalived."
	fi

	mkdir -p $keepalive_conf_path/script

	#Generate configuration files
    \cp $script_path/check_cloudmanager_status.sh $keepalive_conf_path/script
    \cp $script_path/$notify_file $script_path/$notify_file_bak
	\cp $conf_path/$keepalive_conf  $conf_path/$keepalive_conf_bak
	sed -i "s/STATUS/$status/g" $conf_path/$keepalive_conf_bak
	sed -i "s/VIP/$vip/g" $conf_path/$keepalive_conf_bak
	sed -i "s/MASTERIP/$master_ip/g" $conf_path/$keepalive_conf_bak
	sed -i "s/BACKPIP/$slave_ip/g" $conf_path/$keepalive_conf_bak
    sed -i "s/VIP_IP/$vip/g" $script_path/$notify_file_bak

	\mv $script_path/$notify_file_bak $keepalive_conf_path/script/$notify_file
	if [[ $status == "MASTER" ]];then
		\mv $conf_path/$keepalive_conf_bak $keepalive_conf_path/$keepalive_conf
	elif [[ $status == "BACKUP" ]];then
		sed -i '/priority/s#100#80#g' $conf_path/$keepalive_conf_bak
		\mv $conf_path/$keepalive_conf_bak $keepalive_conf_path/$keepalive_conf
	fi
}
recove_keepalived_conf()
{
	keepalived_conf_path=/etc/keepalived
	realserver_conf_path=/etc/rc.d/init.d/realserver.sh
	rm -rf $keepalived_conf_path
	rm -rf $realserver_conf_path

}

case $1 in
	create)
    create_keepalived_conf $2 $3 $4 $5
	;;
	recover)
	recove_keepalived_conf
	;;
	*)
	logger error "usage: $0 {create | recover}" 
	exit 1
	;;
esac
