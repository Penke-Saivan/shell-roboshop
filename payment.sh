#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"
LOGS_FOLDER="/var/log/payment-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FILE_NAME.log"
MYSQL_IP="mysql.believeinyou.fun"
PRESENT_DIRECTORY="$PWD"
mkdir -p  $LOGS_FOLDER

echo -e  "Script started executed $Y at $(date) ........$N" | tee -a $LOG_FILE

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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE



id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding User"

else
    echo -e "user alrerady exits.. $Y ..Skipping>>$N"
fi  

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>LOG_FILE
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "changing directory to app"

rm -rf /app/*
VALIDATE $? "removing existing code "

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "Unzipping code into app"

cd /app 
VALIDATE $? "changing directory to app"
pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "Installing Deps"

cp $PRESENT_DIRECTORY/payment.service /etc/systemd/system/payment.service

systemctl daemon-reload

systemctl enable payment &>>$LOG_FILE
systemctl start payment&>>$LOG_FILE
VALIDATE $? "Enabled and Started payment"

