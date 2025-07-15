#!/bin/bash
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$( echo $0 | cut -d "/" -f1 )
TIMESTAMP=$( date +%Y-%m-%d-%H-%M-%S )
LOG_FILE_NAME="$LOGS_FLOLDER/$LOG_FILE-$TIMESTAMP.log"

echo "Enter password for MySQL root user:"
read MYSQL_ROOT_PASSWORD

Validate() {
    if [ $1 -ne 0 ]
    then 
        echo "$2..failed"
        exit 1
    else
        echo "$2..success"
    fi
}


CHECK_ROOT() {
    if [ $USERID -ne 0 ]
    then 
        echo "Error: you must be a sudo user"
        exit 1
    fi
}

echo "Script started at $TIMESTAMP" >> $LOG_FILE_NAME
CHECK_ROOT


dnf install mysql-server -y >> $LOG_FILE_NAME
Validate $? "Installing mysql-server..."    

systemctl enable mysqld >> $LOG_FILE_NAME
Validate $? "  Enabling MySQL..."

systemctl start mysqld >> $LOG_FILE_NAME
Validate $? "Starting mysql-server..."

mysql -h mysql.rproject.live -uroot -p{$MYSQL_ROOT_PASSWORD} -e "show databases;" >> $LOG_FILE_NAME
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD >> $LOG_FILE_NAME
    Validate $? "MYsql password setup..."
else
    echo -e "MySQL is already configured....$Y Skipping $N"
fi 

