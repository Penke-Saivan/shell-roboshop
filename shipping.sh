#!/bin/bash

USERID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

PRESENT_DIRECTORY="$PWD"
echo "---Present Working Directory is ----$PRESENT_DIRECTORY------------"
LOGS_FOLDER="/var/log/shipping-logs"
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

dnf install maven -y &>>$LOG_FILE



id roboshop
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Adding User"

else
    echo -e "user alrerady exits.. $Y ..Skipping>>$N"
fi  

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading code"

cd /app 
VALIDATE $? "changing directory to app"

rm -rf /app/*
VALIDATE $? "removing existing code "

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Unzipping code into app"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Cleaning packages and deps"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "Moved to folder where pom.xml is present"

cp $PRESENT_DIRECTORY/shipping.service /etc/systemd/system/shipping.service

systemctl daemon-reload

systemctl enable shipping &>>$LOG_FILE
systemctl start shipping&>>$LOG_FILE
VALIDATE $? "Enabled and Started SHipping"

dnf install mysql -y&>>$LOG_FILE

mysql -h mysql.believeinyou.fun -uroot -pRoboShop@1 -e "use cities"

if [ $? -ne 0 ]; then 
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/schema.sql&>>$LOG_FILE
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_IP -uroot -pRoboShop@1 < /app/db/master-data.sql&>>$LOG_FILE
else
     echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE