# DEC-Launchpad---Linux

## Purpose
This project is set up for a data processing pipeline using Linux commands and bash scripts. It covers:
1. File manipulation, 
2. Data automation, 
3. Permissions management, and 
4. Scheduling with cron, & logging.

## Setting up the environment
The server was connected to using ssh in a git bash terminal

    ssh adeboladesoyin@***.**.**.**

Created 3 different sub-directories inside data_pipeline directory for organizing the pipeline

    mkdir data_pipeline
    cd data_pipeline
    mkdir -p input output logs
    ls -l

The input directory would store the data.
The output will store the processed data, and the logs will save the history.

## Data Ingestion and Pre-processing

Data source: This is a csv file provided by the mentor for this project.\
link: https://github.com/dataengineering-community/launchpad/blob/main/Linux/sales_data.csv

A new file called sales_data.csv was created in the /data_pipeline/input directory.

    cd input
    touch sales_data.csv
    nano sales_data.csv

![alt text](Images/Dataimport.png)

A preprocess.sh script was written to clean and prepare the dataset using shebang.

1. The extra_col (the last column which is the 7th column) was removed.
2. The rows where status (column 6) is equal to Failed was filtered out.
3. The final changes made gave a cleaned_sales_data and output as acsv file to the output folder.
4. A success message was echo out after successful cleaning of the dataset.

See below the preprocess.sh script:

    #!/bin/bash

    inputfile=sales_data.csv
    removefile=removecolumn.csv
    outputfile=/home/adeboladesoyin/data_pipeline/output/cleaned_sales_data.csv

    #Removing the last column from the sales_data.csv
    awk -F, '{print $1,$2,$3,$4,$5,$6}' OFS="," "$inputfile" > "$removefile"

    if [ $? -eq 0 ]; then
            echo "Successfully removed the last column" & cat "$removefile"
    else
            echo "dataset cleaning failed"
    fi


#Filtering failed status from the data
awk -F, '$6 != "Failed" {print $1, $2,$3.$4,$5,$6}' OFS ="," "$removefile" > "$outputfile"

#Checking if the command is successful
if [ $? -eq 0 ]; then
        echo "Successfully removed failed status" & cat "$outputfile"
else
        echo "dataset cleaning failed"
fi

**Ensuring the script is executable**

The permission on the preprocess.sh file was seen not to be executable.

Previous output:
    -rw-rw-r-- 1 adeboladesoyin adeboladesoyin 357 Sep 29 23:27 preprocess.sh

The command below was run to give the user an executable permission:

    -rwxrw-r-- 1 adeboladesoyin adeboladesoyin 357 Sep 29 23:27 preprocess.sh


## Automating the Pipeline with Cron Jobs
