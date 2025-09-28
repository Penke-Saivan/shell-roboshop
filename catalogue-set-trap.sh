#!/bin/bash
set -euo pipefail

trap 'echo "There is an error in the the $LINENO, COmmand is: $BASH_COMMAND"' ERR

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"
LOGS_FOLDER="/var/log/catalogue1-logs"
FILE_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$FILE_NAME.log"
MONGO_IP="mongodb.believeinyou.fun"
PRESENT_DIRECTORY="$PWD"
mkdir -p  $LOGS_FOLDER

echo -e "Script started executed $Y at $(date) ........$N" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "Please use $G super user privilege $N" | tee -a $LOG_FILE
    exit 1
else 
    echo -e "Already had $R Super User$N Privilege" | tee -a $LOG_FILE
fi

# VALIDATE(){

#     if [ $1 -ne 0 ]; then
#         echo -e "ERROR::  $2 is $R failure.... $N " | tee -a $LOG_FILE
#         exit 1
#     else
#         echo -e " $2 is $G SUCCESS......$N" | tee -a $LOG_FILE
#     fi        
# }

dnf module disable nodejs -y  &>>$LOG_FILE
echo "Disabling NodeJS"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
echo "Enabling NodeJS"

dnf install nodejs -y  &>>$LOG_FILE
echo "Installing NodeJS"

#check roboshop already exists- if exists skip/create

id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    echo "Adding User"

else
    echo -e "user alrerady exits.. $Y ..Skipping>>$N"
fi    

mkdir -p /app 
echo "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
echo "Downloading code"

cd /app 
echo "changing directory to app"

rm -rf /app/*
echo "removing existing code "

unzip /tmp/catalogue.zip &>>$LOG_FILE
echo "Unzipping code into app"

cd /app 
echo "changing directory to app"

npm install  &>>$LOG_FILE
echo "installing dependencies in the app directory where package.json is present"

cp $PRESENT_DIRECTORY/catalogue.service "/etc/systemd/system/catalogue.service"
echo "copying catalogue to /etc/systemd/system/catalogue.service"

systemctl daemon-reload
echo "Daemon reloaded"

systemctl enable catalogue  &>>$LOG_FILE
echo "Enable catalogue"

systemctl start catalogue
echo "Start catalogue"

cp $PRESENT_DIRECTORY/mongo.repo /etc/yum.repos.d/mongo.repo
echo "Adding mongodb repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
echo "Install mongodb-mongosh client"

INDEX=$(mongosh $MONGO_IP --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGO_IP </app/db/master-data.js &>>$LOG_FILE
    echo "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
echo "Restarted catalogue"
