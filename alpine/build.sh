#!/bin/bash
# coding: utf-8
# Copyright (c) 2018
# Gmail: liuzheng712
#

set -ex

yum update -y
yum install epel-release -y
yum update -y 
yum install wget unzip epel-release nginx sqlite-devel xz gcc automake zlib-devel openssl-devel redis mariadb mariadb-devel mariadb-server supervisor -y

source /dev/stdin <<<  "$(curl http://${nginxip}/require.txt)" 

cd /opt/ 
curl -o ${Python_dist} http://${nginxip}/${Python_dist}
curl -o ${Jumpserver_dist} http://${nginxip}/${Jumpserver_dist}
curl -o ${Coco_dist} http://${nginxip}/${Coco_dist}
curl -o ${Luna_dist} http://${nginxip}/${Luna_dist} 

tar xf ${Python_dist}
unzip ${Jumpserver_dist}
unzip ${Coco_dist}
tar xzf ${Luna_dist}

cd /opt/Python* && ./configure && make && make install
cd /opt/
python3 -m venv py3
source /opt/py3/bin/activate

yum -y install $(cat /opt/jumpserver-master/requirements/rpm_requirements.txt)

pip install -r /opt/jumpserver-master/requirements/requirements.txt
pip install -r /opt/coco-dev/requirements/requirements.txt


mkdir -p /opt/nginx/log && chmod 777 /opt/nginx/log/
mkdir -p /opt/mysql/log /opt/mysql/data /opt/mysql/plugin 
ln -s /opt/mysql/mysql.sock  /var/lib/mysql/mysql.sock
curl -o /etc/nginx/nginx.conf http://${nginxip}/nginx.conf
curl -o /etc/supervisord.conf http://${nginxip}/supervisord.conf 
curl -o /etc/my.cnf http://${nginxip}/mysql.cnf
curl -o /opt/mysql/share/mysql/errmsg.sys http://${nginxip}/errmsg.sys 
curl -o /opt/mysql/mysql_security.sql http://${nginxip}/mysql_security.sql 
curl -o /opt/jumpserver-master/config.py http://${nginxip}/jumpserver_conf.py
curl -o /opt/security.sh http://${nginxip}/security.sh

mysql_install_db
chown -R mysql:mysql /opt/mysql
/usr/bin/mysqld_safe --default-file=/etc/my.cnf 
