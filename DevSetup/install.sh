#!/bin/bash
CurrentDir=$(pwd)
yumArray=(vim gcc make gdb ctags-etags.x86_64 cscope svn automake libtool  glib2.x86_64 glib2-devel.x86_64 git tunctl readline-devel zlib-devel.x86_64)
a_len=${#yumArray[@]}
for ((i=0; i<$a_len; ++i))
do
	echo 开始安装${yumArray[i]}
	yum install ${yumArray[i]} -y
done

#打开vi时默认打开vim,以后登入root时生效
echo alias vi=vim >>~/.bash_profile 

#unalias cp
#移动vim配置文件到用户目录
rm -rf /root/.vim
git clone https://github.com/duxijun/vim.git vim
cd vim
git submodule init
git submodule update
cd ..
cp -f ./vim ~/.vim  -rf
ln -sf /root/.vim/.vimrc /root
#修改打开文件数目
cp -f ./limits.conf /etc/security/limits.conf  
#修改core文件格式
echo "./core.%e.%p" > /proc/sys/kernel/core_pattern

#使用测试小程序
make
./Helloword
make clean



#下载开发代码
#echo 请输入svn的用户名和密码
#svn co http://192.168.1.16/svn/freedbs/trunk ~/trunk

#echo cd ~/trunk/src/sheepdog/ >> ~/.bash_profile
#source ~/.bash_profile

#编译代码

#安装samba
install_samba()
{
	yum install samba -y
	cd $CurrentDir
	setenforce 0
	cp -f ./config /etc/selinux/ 
	cp -f ./smb.conf /etc/samba/
	/sbin/service iptables stop
	/sbin/service smb restart
	chkconfig iptables off
	chkconfig smb on

	#echo 请输入Samba的密码
	smbpasswd -a root
	smbpasswd -e root
	#echo Samba安装完成 请用用户名root登陆

}
#自定义安装



install_samba



