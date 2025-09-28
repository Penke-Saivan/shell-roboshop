#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"
LOGS_FOLDER="/var/log/user1-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FILE_NAME.log"
MONGO_IP="mongodb.believeinyou.fun"
PRESENT_DIRECTORY="$PWD"
mkdir -p  $LOGS_FOLDER

echo "Script started executed $Y at $(date) ........$N" | tee -a $LOG_FILE

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

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

#check roboshop already exists- if exists skip/create

id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding User"

else
    echo -e "user alrerady exits.. $Y ..Skipping>>$N"
fi    

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "changing directory to app"

rm -rf /app/*
VALIDATE $? "removing existing code "

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzipping code into app"

cd /app 
VALIDATE $? "changing directory to app"

npm install  &>>$LOG_FILE
VALIDATE $? "installing dependencies in the app directory where package.json is present"

cp $PRESENT_DIRECTORY/user.service "/etc/systemd/system/user.service"
VALIDATE $? "copying user to /etc/systemd/system/user.service"

systemctl daemon-reload
VALIDATE $? "Daemon reloaded"

systemctl enable user  &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl start user
VALIDATE $? "Start user"

systemctl restart catalogue
VALIDATE $? "Restarted catalogue"
