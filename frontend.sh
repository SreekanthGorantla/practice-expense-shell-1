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
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "Error:: You must have sudo access to execute this command"
        exit 1
    fi
}
#########################################################
# MAIN
#########################################################
LOGS_FOLDER="/var/log/frontend-logs1"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

#########################################################
# create or replace log file directory
#########################################################
mkdir -p $LOGS_FOLDER
echo =====================================================

echo "Script started executing at: $TIMESTAMP" &>> $LOG_FILE_NAME
echo =====================================================

CHECK_ROOT &>> $LOG_FILE_NAME
echo =====================================================

#########################################################
# Install Nginx
#########################################################
dnf install nginx -y &>> $LOG_FILE_NAME
VALIDATE $? "Installing Nginx"
echo =====================================================

#########################################################
# Enable Nginx
#########################################################
systemctl enable nginx &>> $LOG_FILE_NAME
VALIDATE $? "Enable Nginx"
echo =====================================================

#########################################################
# Start Nginx
#########################################################
systemctl start nginx &>> $LOG_FILE_NAME
VALIDATE $? "Start Nginx"
echo =====================================================

#########################################################
# remove all from /usr/share/nginx/html
#########################################################
rm -rf /usr/share/nginx/html/*  &>> $LOG_FILE_NAME
VALIDATE $? "Removing existing version of code"
echo =====================================================

############################################################################################
# Downloading latest frontend code
############################################################################################
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOG_FILE_NAME
VALIDATE $? "Downloading latest frontend code"
echo =====================================================

#########################################################
# Moving HTML directory
#########################################################
cd /usr/share/nginx/html &>> $LOG_FILE_NAME
VALIDATE $? "Moving to HTML directory"
echo =====================================================

#########################################################
# Unzipping latest frontend code
#########################################################
unzip /tmp/frontend.zip $LOG_FILE_NAME
VALIDATE $? "Unzip frontend"
echo =====================================================

############################################################################################
# Copy expense config
############################################################################################
cp /home/ec2-user/practice-expense-shell-1/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copy expense config"
echo =====================================================

#########################################################
# Restart Nginx after all the configuration
#########################################################
systemctl restart nginx &>> $LOG_FILE_NAME
VALIDATE $? "Restarting nginx server"
echo =====================================================