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
for packages in patch make gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel diffutils ca-certificates net-tools libc-client-devel smisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-devel gmp-devel automake libcap freetype freetype-devel cmake;
do yum -y install $packages; done

cd $source_dir
## Download source files ##
wget -c -4 https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
wget -c http://archive.apache.org/dist/apr/apr-1.6.3.tar.gz
wget -c http://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz
wget -c http://sourceforge.net/projects/pcre/files/pcre/8.41/pcre-8.41.tar.gz
wget -c http://archive.apache.org/dist/httpd/httpd-2.4.29.tar.gz
#wget -c http://downloads.mysql.com/archives/get/file/mysql-5.7.19.tar.gz
wget -c http://downloads.mysql.com/archives/get/file/mysql-boost-5.7.19.tar.gz
wget -c http://php.net/distributions/php-7.1.11.tar.gz
wget -c https://files.phpmyadmin.net/phpMyAdmin/4.7.5/phpMyAdmin-4.7.5-all-languages.zip
#wget -c http://www.zhukun.net/lamp_src__zhukun.net_20160107.tar.gz --no-check-certificate
if [ -s lamp_src__zhukun.net_20160107.tar.gz ]; then
  echo "lamp_src__zhukun.net_20160107.tar.gz [found]"
else
  echo "lamp_src__zhukun.net_20160107.tar.gz [not found] [error]"
  exit 1
fi
tar zxvf lamp_src__zhukun.net_20160107.tar.gz
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
cd $source_dir/src
tar -zxvf libiconv-1.15.tar.gz
cd libiconv-1.15
./configure
make && make install

yum install mcrypt libmcrypt libmcrypt-devel mhash mhash-devel
 
/sbin/ldconfig

cd $source_dir/src
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
cd $source_dir/src
tar -zxvf apr-1.6.3.tar.gz
cd apr-1.6.3
./configure --prefix=/usr/local/apr
make
make install

cd $source_dir/src
tar -zxvf apr-util-1.6.1.tar.gz 
cd apr-util-1.6.1
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make
make install

cd $source_dir/src
tar -zxvf pcre-8.41.tar.gz
cd pcre-8.41
./configure -prefix=/usr/local/pcre
make
make install

cd $source_dir/src
tar -zxvf httpd-2.4.29.tar.gz
cd httpd-2.4.29
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ]; then
	rm -f configure
	cp -rf ../apr-1.6.3 ./srclib/apr
	cp -rf ../apr-util-1.6.1 ./srclib/apr-util
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

mkdir -p /home/wwwroot/default
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
sed -i 's,#Include conf/extra/httpd-mpm.conf,Include conf/extra/httpd-mpm.conf,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,#Include conf/extra/httpd-vhosts.conf,Include conf/extra/httpd-vhosts.conf,g' /usr/local/apache2/conf/httpd.conf
#sed -i 's,#LoadModule vhost_alias_module modules/mod_vhost_alias.so,LoadModule vhost_alias_module modules/mod_vhost_alias.so,g' /usr/local/apache2/conf/httpd.conf

sed -i "s,ServerAdmin you@example.com,ServerAdmin $admin_email,g" /usr/local/apache2/conf/httpd.conf
sed -i "s,#ServerName www.example.com:80,ServerName $hostname:80,g" /usr/local/apache2/conf/httpd.conf
sed -i "s,ServerName www.example.com:443,ServerName $hostname:443,g" /usr/local/apache2/conf/extra/httpd-ssl.conf
sed -i "s,ServerAdmin you@example.com,ServerAdmin $admin_email,g" /usr/local/apache2/conf/extra/httpd-ssl.conf

#echo "AddType application/x-httpd-php .php .php3" >> /usr/local/apache2/conf/httpd.conf
#开启php-fpm，参考http://wiki.apache.org/httpd/PHP-FPM
sed -i 's,#LoadModule proxy_module modules/mod_proxy.so,LoadModule proxy_module modules/mod_proxy.so,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,#LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so,LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,/usr/local/apache2/htdocs,/home/wwwroot,g' /usr/local/apache2/conf/httpd.conf
sed -i 's,/usr/local/apache2/docs,/home/wwwroot,g' /usr/local/apache2/conf/extra/httpd-ssl.conf

#enable virtual_hosts
cat /dev/null > /usr/local/apache2/conf/extra/httpd-vhosts.conf
cat > /usr/local/apache2/conf/extra/httpd-vhosts.conf<<eof
<VirtualHost $ip:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot "/home/wwwroot/default"
    ProxyRequests Off
    ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/home/wwwroot/default/\$1
    ServerName www.example.com
    ErrorLog "logs/default-error_log"
    CustomLog "logs/default-access_log" common
</VirtualHost>
eof

chown -R www:www /home/wwwroot

#########################Install Mysql#########################

groupadd mysql
useradd -g mysql -s /sbin/nologin -M mysql

cd $source_dir/src
tar -zxvf mysql-boost-5.7.19.tar.gz
cd mysql-5.7.19
cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_EMBEDDED_SERVER=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DWITH_BOOST=boost

make && make install

chown -R mysql:mysql /usr/local/mysql
#--initialize-insecure means root@localhost is created with an empty password
/usr/local/mysql/bin/mysqld --initialize-insecure --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql
chown -R mysql:mysql /usr/local/mysql/data

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld && chkconfig --level 2345 mysqld on

#according https://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html
#there is no my-default.ini included from MySQL 5.7.18
#so let's create one
cat > /etc/my.cnf<<EOF
[client]
#password   = your_password
port        = 3306
socket      = /tmp/mysql.sock

[mysqld]
port        = 3306
socket      = /tmp/mysql.sock
datadir = /usr/local/mysql/data
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 8M
tmp_table_size = 16M
performance_schema_max_table_instances = 500

explicit_defaults_for_timestamp = true
#skip-networking
max_connections = 500
max_connect_errors = 100
open_files_limit = 65535

log-bin=mysql-bin
binlog_format=mixed
server-id   = 1
expire_logs_days = 10
early-plugin-load = ""

#loose-innodb-trx=0
#loose-innodb-locks=0
#loose-innodb-lock-waits=0
#loose-innodb-cmp=0
#loose-innodb-cmp-per-index=0
#loose-innodb-cmp-per-index-reset=0
#loose-innodb-cmp-reset=0
#loose-innodb-cmpmem=0
#loose-innodb-cmpmem-reset=0
#loose-innodb-buffer-page=0
#loose-innodb-buffer-page-lru=0
#loose-innodb-buffer-pool-stats=0
#loose-innodb-metrics=0
#loose-innodb-ft-default-stopword=0
#loose-innodb-ft-inserted=0
#loose-innodb-ft-deleted=0
#loose-innodb-ft-being-deleted=0
#loose-innodb-ft-config=0
#loose-innodb-ft-index-cache=0
#loose-innodb-ft-index-table=0
#loose-innodb-sys-tables=0
#loose-innodb-sys-tablestats=0
#loose-innodb-sys-indexes=0
#loose-innodb-sys-columns=0
#loose-innodb-sys-fields=0
#loose-innodb-sys-foreign=0
#loose-innodb-sys-foreign-cols=0

default_storage_engine = InnoDB
#innodb_file_per_table = 1
#innodb_data_home_dir = /usr/local/mysql/data
#innodb_data_file_path = ibdata1:10M:autoextend
#innodb_log_group_home_dir = /usr/local/mysql/data
#innodb_buffer_pool_size = 16M
#innodb_log_file_size = 5M
#innodb_log_buffer_size = 8M
#innodb_flush_log_at_trx_commit = 1
#innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout
EOF


#sed -i 's/skip-locking/skip-external-locking/g' /etc/my.cnf
sed -i 's:^#innodb:innodb:g' /etc/my.cnf    #enable innodb

ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -sf /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -sf /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -sf /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe
ln -sf /usr/local/mysql/bin/mysqlcheck /usr/bin/mysqlcheck

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig
ln -sf /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -sf /usr/local/mysql/include/mysql /usr/include/mysql

MySQL_Optimze()
{
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 128#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 16#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 16M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 32M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 32M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 1000" /etc/my.cnf
    elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 256#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 1M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 32#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 32M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 64M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 2000" /etc/my.cnf
    elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 512#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 2M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 32M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 64#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 64M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 128M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 4000" /etc/my.cnf
    elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 1024#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 4M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 64M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 128#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 128M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 128M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 1024M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 256M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 6000" /etc/my.cnf
    elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 512M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 2048#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 8M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 128M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 256#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 256M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 256M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 2048M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 512M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 8000" /etc/my.cnf
    elif [[ ${MemTotal} -ge 32768 ]]; then
        sed -i "s#^key_buffer_size.*#key_buffer_size = 1024M#" /etc/my.cnf
        sed -i "s#^table_open_cache.*#table_open_cache = 4096#" /etc/my.cnf
        sed -i "s#^sort_buffer_size.*#sort_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^read_buffer_size.*#read_buffer_size = 16M#" /etc/my.cnf
        sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 256M#" /etc/my.cnf
        sed -i "s#^thread_cache_size.*#thread_cache_size = 512#" /etc/my.cnf
        sed -i "s#^query_cache_size.*#query_cache_size = 512M#" /etc/my.cnf
        sed -i "s#^tmp_table_size.*#tmp_table_size = 512M#" /etc/my.cnf
        sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 4096M#" /etc/my.cnf
        sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/my.cnf
        sed -i "s#^performance_schema_max_table_instances.*#performance_schema_max_table_instances = 10000" /etc/my.cnf
    fi
}

MySQL_Optimze

/etc/init.d/mysqld start
/usr/local/mysql/bin/mysqladmin -u root password $mysql_root_passwd
if [ $? -ne 0 ]; then
    echo "update MySQL root password failed. Exit."
    exit 1
else:
    echo "update MySQL root password succeed."

cat > /tmp/mysql_sec_script<<EOF
delete from mysql.user where not (User='root') ;
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql -u root -p$mysql_root_passwd -h localhost < /tmp/mysql_sec_script

rm -f /tmp/mysql_sec_script

/etc/init.d/mysqld restart
/etc/init.d/mysqld stop

#########################Install PHP#########################

cd $source_dir/src
tar -zxvf php-7.1.11.tar.gz
cd php-7.1.11
./configure --prefix=/usr/local/php \
--with-apxs2=/usr/local/apache2/bin/apxs \
--with-config-file-path=/usr/local/php/etc \
--with-config-file-scan-dir=/usr/local/php/conf.d \
--with-curl \
--with-jpeg-dir --with-png-dir \
--with-iconv \
--with-freetype-dir \
--with-gd \
--with-iconv-dir \
--with-mcrypt \
--with-bz2 \
--with-gettext \
--with-mhash \
--with-openssl \
--with-zlib \
--with-xmlrpc \
--enable-bcmath \
--enable-fpm --with-fpm-user=www --with-fpm-group=www \
--enable-inline-optimization \
--enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
--enable-mbstring \
--enable-ftp \
--enable-gd-native-ttf \
--enable-intl --with-xsl \
--enable-soap \
--enable-mbregex \
--enable-pcntl \
--enable-session \
--enable-shmop \
--enable-sysvsem \
--enable-sockets \
--enable-zip \
--enable-xml \
--enable-libxml \
--without-pear \
--enable-opcache \
-disable-fileinfo --disable-rpath

#php 5.5 已集成Zend Optimizer+，Optimizer+ 于 2013年3月中旬改名为 Opcache，配置时加上--enable-opcache即可。Zend Opcache 与 eaccelerator 相冲突。
#php 5.5 安装以后默认没有php.ini，把php.ini-production复制成为安装目录下的php.ini。
#经测试如果--with-config-file-path，主配置文件也一样位于安装根目录
#--enable-fastcgi是启用对PHP的FastCGI支持，--enable-fpm是激活对FastCGI模式的fpm支持。 
#从PHP5.3.0以后，FastCGI is now always enabled and cannot be disabled，因此无须加入--enable-fastcgi
#强行加入--enable-fastcgi会导致提示configure: WARNING: unrecognized options: --enable-fastcgi
make ZEND_EXTRA_LIBS='-liconv'
make install
#安装完成以后会在/usr/local/apache2/modules目录下生成libphp7.so，同时执行apachectl -M可以看到已支持php5模块
#同时会向httpd.conf中写入一行LoadModule php7_module，如果打算使用php-fpm，此行可注销
#一篇配置php-fpm很好的文档 http://wiki.apache.org/httpd/PHP-FPM

cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
ln -s /usr/local/php/etc/php.ini /etc/php.ini
ln -s /usr/local/php/etc/php.ini /usr/local/php/php.ini
ln -s /usr/local/php/bin/php /usr/bin/php
ln -s /usr/local/php/bin/phpize /usr/bin/phpize

sed -i 's,LoadModule php7_module,#LoadModule php7_module,g' /usr/local/apache2/conf/httpd.conf
sed -i 's/post_max_size = 8M/post_max_size = 30M/g' /usr/local/php/etc/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 64M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 30M/g' /usr/local/php/etc/php.ini
sed -i 's#;date.timezone =#date.timezone = "Asia/Shanghai"#g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's,enable_dl = Off,enable_dl = On,g' /usr/local/php/etc/php.ini
sed -i 's,display_errors = Off,display_errors = On,g' /usr/local/php/etc/php.ini

sed -i '/opcache.enable=/copcache.enable=1' /usr/local/php/etc/php.ini
sed -i '/opcache.enable_cli=/copcache.enable_cli=1' /usr/local/php/etc/php.ini
sed -i '/opcache.memory_consumption=/copcache.memory_consumption=128' /usr/local/php/etc/php.ini
sed -i '/opcache.interned_strings_buffer=/copcache.interned_strings_buffer=8' /usr/local/php/etc/php.ini
sed -i '/opcache.max_accelerated_files=/copcache.max_accelerated_files=4000' /usr/local/php/etc/php.ini
sed -i '/opcache.revalidate_freq=/copcache.revalidate_freq=60' /usr/local/php/etc/php.ini
sed -i '/opcache.fast_shutdown=/copcache.fast_shutdown=1' /usr/local/php/etc/php.ini

sed -i '/\[opcache\]/azend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20160303/opcache.so"' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,pfsockopen,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket/g' /usr/local/php/etc/php.ini

cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/user = .*/user = www/g' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/group = .*/group = www/g' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/pm.max_children =.*/pm.max_children = 10/' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/pm.max_spare_servers =.*/pm.max_spare_servers = 6/' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/request_terminate_timeout =.*/request_terminate_timeout = 40/' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/request_slowlog_timeout =.*/request_slowlog_timeout = 0/' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/slowlog =.*/slowlog = var\/log\/slow.log/' /usr/local/php/etc/php-fpm.d/www.conf

sed -i '/pid = .*/cpid = run/php-fpm.pid' /usr/local/php/etc/php-fpm.conf
sed -i '/error_log = .*/cerror_log = log/php-fpm.log' /usr/local/php/etc/php-fpm.conf
sed -i '/log_level = .*/clog_level = notice' /usr/local/php/etc/php-fpm.conf

#some clean work
#mv /usr/local/php/etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf.bak
#grep -v '^;' /usr/local/php/etc/php-fpm.conf.bak | grep -v '^$' | grep -v '^[[:space:]]$' > /usr/local/php/etc/php-fpm.conf

chkconfig --level 2345 php-fpm on

#cd $source_dir/src
#tar -zxvf p.tar.gz
#cp p.php /home/wwwroot/default/

cat >/home/wwwroot/default/p.php<<eof
<?php

// Show all information, defaults to INFO_ALL
phpinfo();

// Show just the module information.
// phpinfo(8) yields identical results.
phpinfo(INFO_MODULES);

?>
eof

cat >/home/wwwroot/default/index.html<<eof
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
if [ -d /home/wwwroot/default/pma ]; then
	mv /home/wwwroot/default/pma /home/wwwroot/default/pma_old
fi

cd $source_dir/src
unzip phpMyAdmin-4.7.5-all-languages.zip
mv phpMyAdmin-4.7.5-all-languages /home/wwwroot/default/pma
cp -f /home/wwwroot/default/pma/config.sample.inc.php /home/wwwroot/default/pma/config.inc.php
sed -i "/^\$cfg\['blowfish_secret'\]/c\$cfg\['blowfish_secret'\] = 'i@zhukun.net';" /home/wwwroot/default/pma/config.inc.php

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
/etc/init.d/php-fpm restart
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
echo " * Default Page: http://$ip/p.php"
echo ""
echo " * phpMyAdmin: http://$ip/pma/"
echo ""
echo -e " * MySQL root password: \033[41;37m $mysql_root_passwd \033[0m"
echo ""
echo -e "\033[47;30m * Compiled! Thanks for your using! * \033[0m"
echo ""

## END ##
