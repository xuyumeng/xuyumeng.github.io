# 通过秘钥免密码的登录方法： http://www.unanao.cn/2010/10/01/linux/

SRC_JAR_FILE="build/libs/*.jar"
RUN_DIR="~/task-management/"

# copy to run directory
REMOTE_IP_57="192.168.15.57"
REMOTE_USER_57="centos"

ssh $REMOTE_USER_57@$REMOTE_IP_57 "cd $RUN_DIR ; ./stop.sh"
ssh $REMOTE_USER_57@$REMOTE_IP_57 "cd $RUN_DIR ; rm *.jar"

scp $SRC_JAR_FILE $REMOTE_USER_57@$REMOTE_IP_57:$RUN_DIR 

ssh $REMOTE_USER_57@$REMOTE_IP_57 "cd $RUN_DIR ; ./start.sh"
