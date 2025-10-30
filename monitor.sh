#!/bin/bash

#Searching for the instances of ERROR or failed word in log file

MAIN_DIR=data_pipeline
LOG_DIR=$MAIN_DIR/logs
LOG_FILE=$LOG_DIR/preprocess.log
DATE=$(date '+%Y-%m-%d %H:%M:%S') 

mkdir -p $LOG_DIR

SUMMARY_FILE=$LOG_DIR/monitor_summary.log

echo "" | tee -a $SUMMARY_FILE
echo "==================================" | tee -a $SUMMARY_FILE
echo "$DATE: script monitoring started..." | tee -a $SUMMARY_FILE

#Get the last log in the log file, RS means record seperator
MAX_LOG=$(awk -v RS='' 'END{print}' $LOG_FILE)

#Searching for ERROR or failed word in the preprocess log file
Errorsearch=$(grep -Ei "ERROR|failed" $LOG_FILE)

#Echoing/returning the lines returned with error or failed
wordcount=$(echo $Errorsearch | wc -c)

if [ "$wordcount" -gt 1 ]; then 
    echo "$DATE: checking errors in log file..." | tee -a $SUMMARY_FILE
    echo "$DATE: $wordcount ERROR(s)/Failure(s) found in the preprocess.log file" | tee -a $SUMMARY_FILE
    echo "check details below..." | tee -a $SUMMARY_FILE
    echo $Errorsearch | tee -a $SUMMARY_FILE
    echo "==================================" | tee -a $SUMMARY_FILE
else
    echo "$DATE: No error or failure found" | tee -a $SUMMARY_FILE
    echo "==================================" | tee -a $SUMMARY_FILE
chmod u+x $LOG_FILE $SUMMARY_FILE
fi

# Make this script executable
chmod u+x monitor.sh