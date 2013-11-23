#!/bin/bash
######################################################
#       LAMP Installer for Redhat / CentOS           #
# -------------------------------------------------- #
#       Written by HTTP://WWW.ZHUKUN.NET             #
######################################################

ip=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 {print $1}'`
source_dir=`pwd`
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

## Check ##
if [ $(id -u) != "0" ]; then
	echo "Error: NO PERMISSION! Please login as root to install LAMP."
	exit 1
fi
if [ ! -s /etc/redhat-release ]; then
	echo -e "Error: Your OS is not CentOS/RedHat. Stopped."
	exit 1
fi

## Start ##
clear
echo ""
echo -e "\033[41;37m **************************************** \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *  LAMP Installer for CentOS & RedHat  * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m *  Written By HTTP://WWW.ZHUKUN.NET    * \033[0m"
echo -e "\033[41;37m *                                      * \033[0m"
echo -e "\033[41;37m **************************************** \033[0m"
echo ""

## Set up ##
echo "==========================="
read -p "Enter the MySQL root password ( Default root ): " mysql_root_passwd
if [ "$mysql_root_passwd" = "" ]; then
	mysql_root_passwd="root"
else
	mysql_root_passwd=$mysql_root_passwd
fi
echo ""
echo -e "MySQL root password: $mysql_root_passwd"
echo ""

echo "==========================="
read -p "Enter the default server domain name ( Default $ip ) : " hostname
if [ "$hostname" = "" ]; then
	hostname=$ip
else
	hostname=$hostname
fi
echo ""
echo -e "Server domain name: $hostname"
echo ""

echo "==========================="
read -p "Please enter the server administrator email address ( Default i@zhukun.net) : " admin_email
if [ "$admin_email" = "" ]; then
	admin_email="i@zhukun.net"
else
	admin_email=$admin_email
fi
echo ""
echo -e "Server admin email: $admin_email"
echo "==========================="

## Define ##
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo ""
echo -e "Press any key to start installing LAMP..."
char=`get_char`
echo ""

## Disable SeLinux ##
setenforce 0
if [ -s /etc/selinux/config ]; then
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
fi

## Set timezone ##
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yum install -y ntp
ntpdate -d pool.ntp.org
date

killall mysqld
killall httpd
killall nginx
killall pure-ftpd
killall memcached

yum -y remove httpd*
yum -y remove php*
yum -y remove mysql*

yum -y install yum-fastestmirror
for packages in patch make gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-enhanced fonts-chinese gettext gettext-devel gmp-devel python pspell-devel unzip wget automake libevent libevent-devel libcap;
do yum -y install $packages; done

cd $source_dir
## Download source files ##
wget -c http://www.cmake.org/files/v2.8/cmake-2.8.4.tar.gz      #下载cmake用于编译mysql
wget -c http://sourceforge.net/projects/pcre/files/pcre/8.33/pcre-8.33.tar.gz
wget -c http://archive.apache.org/dist/apr/apr-1.4.8.tar.gz
wget -c http://archive.apache.org/dist/apr/apr-util-1.5.2.tar.gz
wget -c http://archive.apache.org/dist/httpd/httpd-2.4.6.tar.gz
wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
wget -c http://mysql.mirrors.ovh.net/ftp.mysql.com/Downloads/MySQL-5.5/mysql-5.5.34.tar.gz
wget -c http://sourceforge.net/projects/mcrypt/files/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
wget -c http://sourceforge.net/projects/mcrypt/files/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz
wget -c http://sourceforge.net/projects/mhash/files/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
wget -c http://us2.php.net/distributions/php-5.5.5.tar.gz
wget -c http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.0.8/phpMyAdmin-4.0.8-all-languages.tar.gz
wget -c http://soft.vpser.net/lnmp/lnmp0.9-full/p.tar.gz

if [ -s cmake-2.8.4.tar.gz ]; then
  echo "cmake-2.8.4.tar.gz [found]"
else
  echo "cmake-2.8.4.tar.gz [not found] [error]"
  exit 1
fi

if [ -s pcre-8.33.tar.gz ]; then
  echo "pcre-8.33.tar.gz [found]"
else
  echo "pcre-8.33.tar.gz [not found] [error]"
  exit 1
fi

if [ -s apr-1.4.8.tar.gz ]; then
  echo "apr-1.4.8.tar.gz [found]"
else
  echo "apr-1.4.8.tar.gz [not found] [error]"
  exit 1
fi

if [ -s apr-util-1.5.2.tar.gz ]; then
  echo "apr-util-1.5.2.tar.gz [found]"
else
  echo "apr-util-1.5.2.tar.gz [not found] [error]"
  exit 1
fi

if [ -s httpd-2.4.6.tar.gz ]; then
  echo "httpd-2.4.6.tar.gz [found]"
else
  echo "httpd-2.4.6.tar.gz [not found] [error]"
  exit 1
fi

if [ -s libiconv-1.14.tar.gz ]; then
  echo "libiconv-1.14.tar.gz [found]"
else
  echo "libiconv-1.14.tar.gz [not found] [error]"
  exit 1
fi

if [ -s mysql-5.5.34.tar.gz ]; then
  echo "mysql-5.5.34.tar.gz [found]"
else
  echo "mysql-5.5.34.tar.gz [not found] [error]"
  exit 1
fi

if [ -s libmcrypt-2.5.8.tar.gz ]; then
  echo "libmcrypt-2.5.8.tar.gz [found]"
else
  echo "libmcrypt-2.5.8.tar.gz [not found] [error]"
  exit 1
fi

if [ -s mcrypt-2.6.8.tar.gz ]; then
  echo "mcrypt-2.6.8.tar.gz [found]"
else
  echo "mcrypt-2.6.8.tar.gz [not found] [error]"
  exit 1
fi

if [ -s mhash-0.9.9.9.tar.gz ]; then
  echo "mhash-0.9.9.9.tar.gz [found]"
else
  echo "mhash-0.9.9.9.tar.gz [not found] [error]"
  exit 1
fi

if [ -s php-5.5.5.tar.gz ]; then
  echo "php-5.5.5.tar.gz [found]"
else
  echo "php-5.5.5.tar.gz [not found] [error]"
  exit 1
fi

if [ -s phpMyAdmin-4.0.8-all-languages.tar.gz ]; then
  echo "phpMyAdmin-4.0.8-all-languages.tar.gz [found]"
else
  echo "phpMyAdmin-4.0.8-all-languages.tar.gz [not found] [error]"
  exit 1
fi

clear
echo ""
echo "+-----------------------------------------------------------+"
echo "| Download and Check source files successfully              |"
echo "| Please wait 5 seconds, the installation will continue...  |"
echo "+-----------------------------------------------------------+"
echo ""
echo " Please wait..."
sleep 6

#########################Install Plugins#########################
cd $source_dir
tar -zxvf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure
make && make install

cd $source_dir
tar -zxvf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install

cd $source_dir
tar -zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
/sbin/ldconfig

cd $source_dir
tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install

cd $source_dir
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi

ulimit -v unlimited

if [ ! `grep -l "/lib"    '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64'    '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -l '/usr/local/lib'    '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi
/sbin/ldconfig

cat >>/etc/security/limits.conf<<eof
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
eof

cat >>/etc/sysctl.conf<<eof
fs.file-max=65535
eof

#########################Install Apache#########################
cd $source_dir
tar -zxvf apr-1.4.8.tar.gz
cd apr-1.4.8
./configure --prefix=/usr/local/apr
make
make install

cd $source_dir
tar -zxvf apr-util-1.5.2.tar.gz 
cd apr-util-1.5.2
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make
make install

cd $source_dir
tar -zxvf pcre-8.33.tar.gz
cd pcre-8.33
./configure -prefix=/usr/local/pcre
make
make install

cd $source_dir
tar -zxvf httpd-2.4.6.tar.gz
cd httpd-2.4.6
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ]; then
	rm -f configure
	cp -rf ../apr-1.4.8 ./srclib/apr
	cp -rf ../apr-util-1.5.2 ./srclib/apr-util
	./buildconf
	./configure --prefix=/usr/local/apache2 --with-mysql=/usr/local/mysql --with-apr=/usr/local/apr/ --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre/ --enable-deflate --enable-expires --enable-static-support --enable-rewrite --enable-so --enable-headers --enable-ssl --with-ssl --with-z --enable-cache --enable-file-cache --enable-disk-cache --enable-mem-cache --disable-userdir --enable-lib64 --libdir=/usr/lib64
else
	./configure --prefix=/usr/local/apache2 --with-mysql=/usr/local/mysql --with-apr=/usr/local/apr/ --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre/ --enable-deflate --enable-expires --enable-static-support --enable-rewrite --enable-so --enable-headers --enable-ssl --with-ssl --with-z --enable-cache --enable-file-cache --enable-disk-cache --enable-mem-cache --disable-userdir
fi
make && make install
cp -f /usr/local/apache2/bin/apachectl /etc/rc.d/init.d/httpd
chmod 755 /etc/init.d/httpd
sed -i 's,#!/bin/sh,#!/bin/bash,g' /etc/init.d/httpd
sed -i '1a\# chkconfig: 35 85 15' /etc/init.d/httpd
sed -i '2a\# description: Apache httpd' /etc/init.d/httpd
chkconfig --level 2345 httpd on

mkdir -p /home/wwwroot
rm -rf /usr/local/apache2/htdocs
ln -s /home/wwwroot /usr/local/apache2/htdocs
groupadd www
useradd -s /sbin/nologin -M -g www www
sed -i 's/User daemon/User www/g' /usr/local/apache2/conf/httpd.conf
sed -i 's/Group daemon/Group www/g' /usr/local/apache2/conf/httpd.conf
sed -i 's,index.html,index.html index.php,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,AllowOverride None,AllowOverride All,g' /usr/local/apache2/conf/httpd.conf   #开启伪静态
sed -i 's,#LoadModule rewrite_module,LoadModule rewrite_module,g' /usr/local/apache2/conf/httpd.conf   #开启伪静态
sed -i 's,Options Indexes FollowSymLinks,Options FollowSymLinks,g' /usr/local/apache2/conf/httpd.conf  #关闭目录浏览

sed -i "s,#ServerName www.example.com:80,ServerName $hostname:80,g" /usr/local/apache2/conf/httpd.conf
sed -i "s,ServerName www.example.com:80,ServerName $hostname:80,g" /usr/local/apache2/conf/httpd.conf
sed -i "s,ServerName www.example.com:443,ServerName $hostname:443,g" /usr/local/apache2/conf/extra/httpd-ssl.conf
sed -i "s,ServerAdmin you@example.com,ServerAdmin $admin_email,g" /usr/local/apache2/conf/httpd.conf
sed -i "s,ServerAdmin you@example.com,ServerAdmin $admin_email,g" /usr/local/apache2/conf/extra/httpd-ssl.conf
echo "AddType application/x-httpd-php .php .php3" >> /usr/local/apache2/conf/httpd.conf
sed -i 's,/usr/local/apache2/htdocs,/home/wwwroot,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,/usr/local/apache2/docs,/home/wwwroot,g' /usr/local/apache2/conf/extra/httpd-ssl.conf
sed -i 's,/usr/local/apache2/docs,/home/wwwroot,g' /usr/local/apache2/conf/extra/httpd-vhosts.conf
chown -R www:www /home/wwwroot

#########################Install Mysql#########################

cd $source_dir
tar -zxvf cmake-2.8.4.tar.gz
cd cmake-2.8.4
./configure && make && make install

groupadd mysql
useradd -r -g mysql mysql -s /sbin/nologin -d /dev/null

cd $source_dir
tar -zxvf mysql-5.5.34.tar.gz
cd mysql-5.5.34
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_READLINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_USER=mysql -DWITH_DEBUG=0 -DMYSQL_TCP_PORT=3306
make && make install

chown -R mysql:mysql /usr/local/mysql
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
chown -R mysql:mysql /usr/local/mysql/data

cp support-files/my-medium.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld && chkconfig --level 2345 mysqld on
sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
sed -i 's/log-bin=mysql-bin/#log-bin=mysql-bin/g' /etc/my.cnf
sed -i 's/binlog_format=mixed/#binlog_format=mixed/g' /etc/my.cnf

ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk

/etc/init.d/mysqld start
/usr/local/mysql/bin/mysqladmin -u root password $mysql_root_passwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysql_root_passwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password=''; 
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysql_root_passwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysql restart
/etc/init.d/mysql stop

#########################Install PHP#########################

cd $source_dir
tar -zxvf php-5.5.5.tar.gz
cd php-5.5.5
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache2/bin/apxs --with-config-file-path=/usr/local/php --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv --with-curl=ext/curl --with-gd --with-mcrypt --with-gettext --with-mhash --with-zlib --with-xmlrpc --enable-mbstring --enable-soap --enable-mbregex --enable-zip --enable-xml --enable-libxml --enable-bcmath --enable-fpm --without-pear --enable-opcache
#php 5.5 已集成Zend Optimizer+，Optimizer+ 于 2013年3月中旬改名为 Opcache，配置时加上--enable-opcache即可。Zend Opcache 与 eaccelerator 相冲突。
#php 5.5 安装以后默认没有php.ini，把php.ini-production复制成为安装目录下的php.ini。
#经测试如果--with-config-file-path，主配置文件也一样位于安装根目录
#--enable-fastcgi是启用对PHP的FastCGI支持，--enable-fpm是激活对FastCGI模式的fpm支持。 
#从PHP5.3.0以后，FastCGI is now always enabled and cannot be disabled，因此无须加入--enable-fastcgi
#强行加入--enable-fastcgi会导致提示configure: WARNING: unrecognized options: --enable-fastcgi
make ZEND_EXTRA_LIBS='-liconv'
make install
#安装完成以后会在/usr/local/apache2/modules目录下生成libphp5.so，同时执行apachectl -M可以看到已支持php5模块
#同时会向httpd.conf中写入一行LoadModule php5_module
cp php.ini-production /usr/local/php/php.ini
ln -s /usr/local/php/php.ini /etc/php.ini
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize

sed -i 's/post_max_size = 8M/post_max_size = 10M/g' /usr/local/php/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 64M/g' /usr/local/php/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' /usr/local/php/php.ini
sed -i 's#;date.timezone =#date.timezone = "Asia/Shanghai"#g' /usr/local/php/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/php.ini

sed -i 's/;opcache.enable=0/opcache.enable=1/g' /usr/local/php/php.ini
sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' /usr/local/php/php.ini
sed -i 's/;opcache.memory_consumption=64/opcache.memory_consumption=128/g' /usr/local/php/php.ini
sed -i 's/;opcache.interned_strings_buffer=4/opcache.interned_strings_buffer=8/g' /usr/local/php/php.ini
sed -i 's/;opcache.max_accelerated_files=2000/opcache.max_accelerated_files=4000/g' /usr/local/php/php.ini
sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=60/g' /usr/local/php/php.ini
sed -i 's/;opcache.fast_shutdown=0/opcache.fast_shutdown=1/g' /usr/local/php/php.ini

sed -i '1871a\zend_extension=\/usr\/local\/php\/lib\/php\/extensions\/no-debug-zts-20121212\/opcache.so' /usr/local/php/php.ini
sed -i 's/disable_functions =/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/php.ini

cd $source_dir
tar -zxvf p.tar.gz
cp p.php /home/wwwroot

cat >/home/wwwroot/index.html<<eof
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>LAMP一键安装包</title>
</head>
<body>
<center>
<p><br /><br /><br /><br /><br /><br /></p>
<p>恭喜，LAMP一键安装包安装成功！</p>
<p></p>
<p><a href="/p.php" target="_blank">PHP探针</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/pma" target="_blank">phpMyAdmin</a></p>
<p></p>
<p>作者网站：<a href="http://www.zhukun.net" target="_blank">http://www.zhukun.net</a></p>
<p></p>
<p></p>
</center>
</body>
</html>
eof

#########################Install phpMyAdmin#########################
##  ##
mkdir /home/wwwroot
if [ -d /home/wwwroot/pma ]; then
	mv /home/wwwroot/pma /home/wwwroot/pma_old
fi

cd $source_dir
tar -zxvf phpMyAdmin-4.0.8-all-languages.tar.gz
mv phpMyAdmin-4.0.8-all-languages /home/wwwroot/pma
cp -f /home/wwwroot/pma/config.sample.inc.php /home/wwwroot/pma/config.inc.php
sed -i "s#\['blowfish_secret'\] = ''#['blowfish_secret'] = 'i@zhukun.net'#g" /home/wwwroot/pma/config.inc.php

## others ##
mkdir /home/wwwlogs

chmod 777 /home/wwwlogs
chmod 755 /home/wwwroot
chown -R www:www /home/wwwroot

## Check program ##
clear
echo ""
if [ -d /usr/local/mysql ]; then
	echo " > MySQL      [found]"
	else
	echo " > MySQL      [not found] [error] [get help in http://www.zhukun.net]"
fi
if [ -d /usr/local/apache2 ]; then
	echo " > Apache     [found]"
	else
	echo " > Apache     [not found] [error] [get help in http://www.zhukun.net]"
fi
if [ -d /usr/local/php ]; then
	echo " > PHP        [found]"
	else
	echo " > PHP        [not found] [error] [get help in http://www.zhukun.net]"
fi
echo ""

## Start services ##
/etc/init.d/mysqld restart
/etc/init.d/httpd restart

## Completed ##
echo ""
echo -e "\033[41;37m ***************************************************** \033[0m"
echo -e "\033[41;37m *                                                   * \033[0m"
echo -e "\033[41;37m *         LAMP Installer for CentOS & RedHat        * \033[0m"
echo -e "\033[41;37m *                                                   * \033[0m"
echo -e "\033[41;37m *         Website: http://www.zhukun.net            * \033[0m"
echo -e "\033[41;37m *                                                   * \033[0m"
echo -e "\033[41;37m ***************************************************** \033[0m"
echo ""
echo " * Default Page: http://$ip/"
echo ""
echo " * phpMyAdmin: http://$ip/pma/"
echo ""
echo -e " * MySQL root password: \033[41;37m $mysql_root_passwd \033[0m"
echo ""
echo -e "\033[47;30m * Compiled! Thanks for your using! * \033[0m"
echo ""

## END ##
