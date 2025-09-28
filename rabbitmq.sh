#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"

FILE_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FOLDER="/var/log/$FILE_NAME-logs"
LOG_FILE="$LOGS_FOLDER/$FILE_NAME.log"
START_TIME=$(date +%s)
mkdir -p  $LOGS_FOLDER

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

cp $PRESENT_DIRECTORY/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo&>>LOG_FILE

dnf install rabbitmq-server -y&>>LOG_FILE
VALIDATE $? "Install RabbitMQ"
systemctl enable rabbitmq-server&>>LOG_FILE
VALIDATE $? "Enable RabbitMQ"
systemctl start rabbitmq-server&>>LOG_FILE
VALIDATE $? "Start RabbitMQ"

rabbitmqctl list_users | grep 'roboshop'

if [ $? -ne 0 ]; then 
    echo "Already user exits"
else
    rabbitmqctl add_user roboshop roboshop123
    echo -e "Added user $G-RobOSHOP$N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting permissions"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"