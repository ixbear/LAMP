LAMP
====

LAMP 是 Linux 平台下 Apache + Mysql + PHP 的一键安装程序。本安程装仅适用于 Redhat / CentOS 系统。

特点：
本安装程序的软件包是自2013.10.01以来的最新版本。
httpd-2.4.6.tar.gz
mysql-5.5.34.tar.gz
php-5.5.5.tar.gz
Apache 作为老牌的 HTTP 软件，其地位不必多说。而Apache 2.4 版的产生，号称在速度上已超越了 Nginx。
PHP 5.5.5 是目前 PHP 5 系列的最新版，经过测试，可以兼容目前主流的 Blog、CMS、BBS 等程序。本人使用WordPress，经测试，完全兼容。

一些说明：
本一健安装程序不包含
由于 Zend 已被 PHP 公司收购，Zend Optimizer 已更名为 Zend OPcache，且集成 PHP 5.5 的安装程序中。只需在安装 PHP 5.5 的时候加上--enable-opcache即可。
本程序不带 eaccelerator，因为 Zend Opcache 与 eaccelerator 相冲突。
