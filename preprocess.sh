#!/bin/bash

#create main directory and subdirectories
MAIN_DIR=data_pipeline
INPUT_DIR=$MAIN_DIR/input
OUTPUT_DIR=$MAIN_DIR/output
LOG_DIR=$MAIN_DIR/logs
SUMMARY_FILE=
DATE=$(date '+%Y-%m-%d %H:%M:%S') 

#create the directories if they do not exist
mkdir -p $INPUT_DIR $OUTPUT_DIR $LOG_DIR

#create files for logs and dataset
INPUT_FILE=$INPUT_DIR/sales_data.csv
OUTPUT_FILE=$OUTPUT_DIR/cleaned_sales_data.csv
LOG_FILE=$LOG_DIR/preprocess.log

URL="https://raw.githubusercontent.com/kabirmohdo/launchpad/main/Linux/sales_data.csv"

#Start logging
echo "==================================" | tee -a $LOG_FILE
echo "Directories created if not exist" | tee -a $LOG_FILE
echo " $DATE: Data Ingestion starting..." | tee -a $LOG_FILE
echo " $DATE: Downloading sales data from $URL" | tee -a $LOG_FILE

#download the sales data file to the input directory
curl -s -o $INPUT_FILE $URL
if [ $? -eq 0 ]; then
    echo " $DATE: Data downloaded successfully to $INPUT_FILE" | tee -a $LOG_FILE

    #Data Cleaning and Preprocessing
    echo " $DATE: Data Preprocessing starting..." | tee -a $LOG_FILE

    #remove the last column and row where status is failed
    awk -F, 'NR>1 {NF--; if($NF!="Failed"){for(i=1;i<=NF;i++) printf "%s%s", $i,(i==NF?ORS:OFS)}}' OFS=, "$INPUT_FILE" >> "$OUTPUT_FILE"
    if [ $? -eq 0 ]; then
        echo " $DATE: Data Preprocessing & cleaning completed successfully. Cleaned data saved to $OUTPUT_FILE" | tee -a $LOG_FILE
    else
        echo " ERROR: $DATE: Data Preprocessing and cleaning failed." | tee -a $LOG_FILE
        echo "==================================" | tee -a "$LOG_FILE"
        exit 1
    fi

else
    echo " ERROR: $DATE: Failed to download sales data from $URL" | tee -a $LOG_FILE
    echo " $DATE: Hence, data preprocessing cannot be started." | tee -a $LOG_FILE
    echo "==================================" | tee -a "$LOG_FILE"
    exit 1

fi
echo "==================================" | tee -a "$LOG_FILE"

# Make this script executable (optional)
chmod u+x preprocess.sh


