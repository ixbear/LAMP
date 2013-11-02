LAMP
====

LAMP 是 Linux 平台下 Apache + Mysql + PHP 的一键安装程序。本安程装仅适用于 Redhat / CentOS 系统。

特点：

本安装程序的软件包是自2013.10.01以来的最新版本。

httpd-2.4.6.tar.gz

mysql-5.5.34.tar.gz

php-5.5.5.tar.gz

phpMyAdmin-4.0.8-all-languages.tar.gz

Apache 作为老牌的 HTTP 软件，在 Web 服务器市场多年排名第一。而 Apache 2.4 版的发布，号称在速度上已超越了 Nginx。

PHP 5.5.5 是目前 PHP 5 系列的最新版，经过测试，可以兼容目前主流的 Blog、CMS、BBS 等程序。本人的 WordPress 使用一切正常。

PHP 参数已作优化，部分参数参考了 Godaddy / Bluehost 等主机商，除去服务器稳定因素，几乎可以得到与 Godaddy / Bluehost 一样的性能体验。

一些说明：

由于 Zend 已被 PHP 公司收购，Zend Optimizer 已更名为 Zend OPcache，且集成在 PHP 5.5 的安装程序中。只需在安装 PHP 5.5 的时候加上--enable-opcache即可。
本程序不带 eaccelerator，因为 Zend Opcache 与 eaccelerator 相冲突。

联系：

作者网站：http://www.zhukun.net

作者邮箱：i@zhukun.net
