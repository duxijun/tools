#!/usr/bin/env python

from com_logger import *
import os
import commands
import sys
home=sys.path[0]

def create_ha_conf(ismaster,masterip,backupip,vip):
	if ismaster == True:
		status = "MASTER"
	else:
		status = "BACKUP"
	ret=os.system('sh %s/cloudmanager_ha_conf.sh create %s %s %s %s' %(home,status,masterip,backupip,vip))
	ret = ret >> 8
	if ret != 0 :
		logger.error('create ha conf failed!')
		return 1
	else:
		logger.info('create ha conf  successed!')
		return 0

def release_ha_conf():
	ret=os.system('sh %s/cloudmanager_ha_conf.sh recover' %(home) )
	ret = ret >> 8
	if ret != 0 :
		logger.error('release ha conf failed!')
		return 1
	else:
		logger.info('release ha conf successed!')
		return 0

def start_ha():
	ret=os.system('sh %s/init_ha.sh start' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('start ha failed!')
		return 1
	else:
		logger.info('start ha successed!')
		return 0

def stop_ha():
	ret=os.system('sh %s/init_ha.sh stop' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('stop ha failed!')
		return 1
	else:
		logger.info('stop ha successed!')
		return 0

def status_ha():
	ret=os.system('sh %s/init_ha.sh status' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('cloudmanager is stopped!')
		return 1
	else:
		logger.info('cloudmanager is running!')
		return 0


