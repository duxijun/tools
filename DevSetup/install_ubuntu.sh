#!/bin/bash
MY_HOME_PATH=/home/dxj
CurrentDir=$(pwd)
yumArray=(vim gcc g++ make cmake  gdb ctags-etags.x86_64 cscope svn automake libtool  glib2.x86_64 glib2-devel.x86_64 lrzsz tunctl readline-devel zlib-devel.x86_64 pyflakes)
a_len=${#yumArray[@]}
for ((i=0; i<$a_len; ++i))
do
	echo 开始安装${yumArray[i]}
	sudo apt-get install ${yumArray[i]} -y
done

#打开vi时默认打开vim,以后登入root时生效
echo alias vi=vim >>~/.bash_profile 

#unalias cp

#配置github
git config --global user.name "duxijun"
git config --global user.email "duxijun0703@gmail.com"

#移动vim配置文件到用户目录
rm -rf ${MY_HOME_PAHT}/.vim
git clone https://github.com/duxijun/vim.git vim
cd vim
git submodule init
git submodule update
cd ..
cp -f ./vim ~/.vim  -rf
ln -sf ${MY_HOME_PATH}/.vim/.vimrc ${MY_HOME_PATH}
#rm -rf vim
#修改打开文件数目
sudo cp -f ./limits.conf /etc/security/limits.conf  
#修改core文件格式
sudo echo "./core.%e.%p" > /proc/sys/kernel/core_pattern


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
	sudo apt-get install samba -y
	cd $CurrentDir
	setenforce 0
	cp -f ./config /etc/selinux/ 
	cp -f ./smb.conf /etc/samba/
	/sbin/service iptables stop
	/sbin/service smb restart
	chkconfig iptables off
	chkconfig smb on

	#echo 请输入Samba的密码
	smbpasswd -a dxj
	smbpasswd -e dxj
	#echo Samba安装完成 请用用户名root登陆

}
#自定义安装



#install_samba



