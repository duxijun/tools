#!/usr/bin/env python

from com_logger import *
import commands
import os
import sys
home=sys.path[0]


def create_account(peerIP ,ismaster):
	if ismaster == True:
		status = "MASTER"
	else:
		status = "BACKUP"
	ret=os.system('sh %s/sync_mysql.sh create %s %s' %(home,peerIP,status))
	ret = ret >> 8
	if ret != 0 :
		logger.error('create account failed!')
		return 1
	else :
		logger.info('create account successed!')
		return 0

def set_sync(peerIP,file,pos):
	logger.info ('peerip=%s,file=%s,pos=%s' %(peerIP,file,pos))
	ret=os.system('sh %s/sync_mysql.sh sync %s %s %s' %(home,peerIP,file,pos))
	ret = ret >> 8
	if ret != 0 :
		logger.error('set mysql sync failed!')
		return 1
	else :
		logger.info('set mysql sync successed!')
		return 0


def start_sync():
	ret=os.system('sh %s/sync_mysql.sh start' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('start mysql sync failed!')
		return 1
	else :
		logger.info('start mysql sync successed!')
		return 0



def stop_sync():
	ret=os.system('sh %s/sync_mysql.sh stop' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('stop mysql sync  failed!')
		return 1
	else :
		logger.info('stop mysql sync successed!')
		return 0


def check_sync():
	ret=os.system('sh %s/sync_mysql.sh status' %(home))
	ret = ret >> 8
	if ret != 0 :
		logger.error('mysql sync  is stopped!')
		return 1
	else :
		logger.info('mysql sync is ok!')
		return 0

def read_sync():
	#ret=os.popen('cat mysql_info.out').read()
	cmd_status,cmd_result=commands.getstatusoutput('cat %s/mysql_info.out' %(home))
	if cmd_status != 0 or len(cmd_result)==0:
		logger.error('mysql info  is empty!')
		sys.exit()
	ret = ""
	for line in cmd_result.split('\n'):
		ret += line
		ret += ','
	ret = ret.split(',')
	file = ret[0]
	pos = ret[1]
	return (cmd_status,file, pos)


