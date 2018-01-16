#!/bin/sh
time=`date +"%F_%H-%M"`
DATABASE="testlink"	#Write your database name
back_name="$DATABASE.$time.gz"

REMOTE_SERVER_USER="centos" 
REMOTE_SERVER_IP="192.168.15.57"
REMOTE_BACKUP_DIR="~/database-backup"

# 1. config mysqldump username and password : https://dev.mysql.com/doc/refman/5.6/en/mysql-config-editor.html
# 2. config login by ssh key

cd /home/ubuntu/backup-script

#backup to local
mysqldump --login-path=client --single-transaction $DATABASE | gzip > $back_name

find . -type f -mtime +7 | xargs rm -rf

# backup to remote
# 通过秘钥免登陆的设置方法: http://www.unanao.cn/2007/07/08/linux/
echo $back_name 
scp ${back_name} $REMOTE_SERVER_USER@$REMOTE_SERVER_IP:$REMOTE_BACKUP_DIR

ssh $REMOTE_SERVER_USER@$REMOTE_SERVER_IP "cd $REMOTE_BACKUP_DIR; find . -type f -mtime +7 | xargs rm -rf" 

cd -
