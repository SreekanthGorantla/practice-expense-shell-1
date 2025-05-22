#!/bin/bash

#########################################################
# check user
#########################################################
USERID=$(id -u)

#########################################################
# Add colours to the text
#########################################################
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#########################################################
# Function to validate
#########################################################
VALIDATE(){
    if [ $1 -ne 0]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -2 "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0]
    then
        echo "Error:: You must have sudo access to execute this command"
        exit 1
    fi
}

#########################################################
# MAIN
#########################################################
LOGS_FOLDER="/var/log/backend-logs1"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

mkdir -p $LOGS_FOLDER  &>> $LOG_FILE_NAME
echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

CHECK_ROOT

#########################################################
# disable,enable nodejs version
#########################################################
dnf module disable nodejs -y &>> $LOG_FILE_NAME
VALIDATE $? "Disabling existing default Nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE_NAME
VALIDATE $? "Enabling default Nodejs latest version"

#########################################################
# Installing Nodejs
#########################################################
dnf install nodejs -y  &>> $LOG_FILE_NAME
VALIDATE $? "Installing Nodejs"

#########################################################
# Add expense user
#########################################################
id expense &>> $LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>> $LOG_FILE_NAME
    VALIDATE $? "Adding Expense user"
else
    echo -e "Expense user already exists ... $Y SKIPPING $N"
fi

#########################################################
# Create app directory
#########################################################
mkdir -p /app &>> $LOG_FILE_NAME
VALIDATE $? "Creating app directory"

#########################################################
# Downloading backend
#########################################################
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading backend"

#########################################################
# Remove everything from /app folder
#########################################################
cd /app
rm -rf /app/* &>> $LOG_FILE_NAME

#########################################################
# Unzip the backend
#########################################################
unzip /tmp/backend.zip &>> $LOG_FILE_NAME
VALIDATE $? "Unzip backend"

#########################################################
# Install npm
#########################################################
npm install &>> $LOG_FILE_NAME
VALIDATE $? "Installing dependencies"


