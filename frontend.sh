#!/bin/bash
USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$( echo $0 | cut -d "/" -f1 )
TIMESTAMP=$( date +%Y-%m-%d-%H-%M-%S )
LOG_FILE_NAME="$LOGS_FLOLDER/$LOG_FILE-$TIMESTAMP.log"

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
    if [ $USERID -ne 0]
    then 
        echo "Error: you must be a sudo user"
        exit 1
    fi
}


echo "Script started at $TIMESTAMP" >> $LOG_FILE_NAME
CHECK_ROOT
dnf install nginx -y >> $LOG_FILE_NAME
VAlidate $? "Installing nginx..." 

systemctl enable nginx >> $LOG_FILE_NAME
Validate $? "Enabling nginx..." 

systemctl start nginx >> $LOG_FILE_NAME
Validate $? "Starting nginx..."

rm -rf /usr/share/nginx/html/* >> $LOG_FILE_NAME
Validate $? "Removing default nginx files..."

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip >> $LOG_FILE_NAME
Validate $? "Downloading frontend files..."

cd /usr/share/nginx/html/ >> $LOG_FILE_NAME
unzip /tmp/frontend.zip >> $LOG_FILE_NAME
Validate $? "Unzipping frontend files..."

cp /home/ec2-user/expense_script/expense.conf /etc/nginx/default.d/expense.conf >> $LOG_FILE_NAME
Validate $? "Copying frontend script..."


systemctl restart nginx >> $LOG_FILE_NAME
Validate $? "Restarting nginx..." 


# algorithm:
#     1.check the root access
#     2.store the logs
#     3.tru to use colors
#     4.install mysql-server
#     5.enable and start 
#     6.set the root password 

