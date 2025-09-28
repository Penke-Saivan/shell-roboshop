
#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"
LOGS_FOLDER="/var/log/mongodb-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FILE_NAME.log"

mkdir -p  $LOGS_FOLDER
START_TIME=$(date +%s)
echo "Script started executed at $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "Please use $G super user privilege $N" | tee -a $LOG_FILE
    exit 1
else 
    echo -e "Already had $R Super User$N Privilege" | tee -a $LOG_FILE
fi

VALIDATE(){

    if [ $1 -ne 0 ]; then
        echo -e "ERROR::  $2 is $R failure.... $N " | tee -a $LOG_FILE
        exit 1
    else
        echo -e " $2 is $G SUCCESS......$N" | tee -a $LOG_FILE
    fi        
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disbale Redis module"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable Redis module"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Install Redis"

# /etc/redis/redis.conf --protected-mode
# vim /etc/redis/redis.conf
# 127.0.0.1 to 0.0.0.0 in /etc/redis/redis.conf

sed -i "/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf
VALIDATE $? "Allowing Remote connections to Redis"

sed -i "/protected-mode/c protected-mode no" /etc/redis/redis.conf
VALIDATE $? "Not allowing protected-mode"

systemctl enable redis  &>>$LOG_FILE
VALIDATE $? "Enable Redis"

systemctl start redis  &>>$LOG_FILE
VALIDATE $? "Start Redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"