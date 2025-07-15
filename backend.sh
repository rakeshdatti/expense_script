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
    if [ $USERID -ne 0 ]
    then 
        echo "Error: you must be a sudo user"
        exit 1
    fi
}

echo "Script started at $TIMESTAMP"&>> $LOG_FILE_NAME
CHECK_ROOT

dnf module disable nodejs -y &>> $LOG_FILE_NAME
Validate $? "Disabling Node.js module..."

dnf enable nodejs:20 -y &>> $LOG_FILE_NAME
Validate $? "Enabling Node.js 20 module..."

dnf install nodejs -y &>> $LOG_FILE_NAME
Validate $? "Installing Node.js..." 

id expense &>> $LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>> $LOG_FILE_NAME
    Validate $? "Creating expense user..." 
else
    echo -e "Expense user already exists...$Y Skipping $N"
fi

mkdir -p /app &>> $LOG_FILE_NAME
Validate $? "Creating /app directory..."

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
Validate $? "Downloading backend files..."

cd /app &>> $LOG_FILE_NAME 
unzip /tmp/backend.zip &??> $LOG_FILE_NAME
Validate $? "Unzipping backend files..."

npm install &>> $LOG_FILE_NAME
Validate $? "Installing Node.js dependencies..."

cp /home/ec2-user/expense_script/backend.sh /etc/systemd/system/backend.service &>> $LOG_FILE_NAME
Validate $? "Copying backend script..."

systemctl daemon-reload &>> $LOG_FILE_NAME
Validate $? "Reloading systemd daemon..."

dnf install mysql -y    &>> $LOG_FILE_NAME 
Validate $? "Installing MySQL..."

mysql -h mysql.rproject.live -uroot -p{$MYSQL_ROOT_PASSWORD} < /app/schema/backend.sql &>> $LOG_FILE_NAME
Validate $? "Setting up MySQL schema..."

systemctl restart backend &>> $LOG_FILE_NAME
Validate $? "Restarting backend service..." 





