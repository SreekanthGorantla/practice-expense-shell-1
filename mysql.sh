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
# 
#########################################################
VALIDATE(){
    if [ $1 != 0 ]
    then
    echo -e "$2 ... $R FAILURE $N"
    exit 1
    else
    echo -e "$2 ... $G SUCCESS $N"
    fi
}

#########################################################
# MAIN
#########################################################
LOGS_FOLDER="/var/log/expense-logs1"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"


echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME

if [ $USERID != 0 ]
then
echo "Error:: You must have Sudo access to execute this command"
exit 1
fi

for package in @$
do
    dnf list installed $package &>> $LOG_FILE_NAME
    if [ $? -ne 0 ]
    then
    dnf install $package -y &>> $LOG_FILE_NAME
    VALIDATE $? "Installing $package"
    else
    echo -e "$package already installed $Y ... INSTALLED $N"
    fi
done