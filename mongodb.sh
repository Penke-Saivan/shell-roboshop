
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongodb repo"

dnf install mongodb-org -y 
VALIDATE $? "Installing mongodb"

systemctl enable mongod
VALIDATE $? "Enable mongodb"

systemctl start mongod
VALIDATE $? "start mongodb"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf
VALIDATE $? "Allowing remote connections to mongodb"

systemctl restart mongod
VALIDATE $? "restart mongodb"