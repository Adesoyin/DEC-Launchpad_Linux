# DEC-Launchpad-Linux

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
5. Finally, the output and error was written into a log file called preprocess.log in /data_pipeline/log directory

See below the preprocess.sh script:

    #!/bin/bash

    inputfile=home/adeboladesoyin/data_pipeline/input/sales_data.csv
    removefile=removecolumn.csv
    outputfile=/home/adeboladesoyin/data_pipeline/output/cleaned_sales_data.csv
    logfile=/home/adeboladesoyin/data_pipeline/logs/preprocess.log

    #Removing the last column from the sales_data.csv
    awk -F, '{print $1,$2,$3,$4,$5,$6}' OFS="," "$inputfile" > "$removefile"

    if [ $? -eq 0 ]; then
            echo "Successfully removed the last column" & cat "$removefile"
    else
            echo "Last column not successfully removed"
    fi


    #Filtering failed status from the data
    awk -F, '$6 != "Failed" {print $1, $2,$3.$4,$5,$6}' OFS ="," "$removefile" > "$outputfile"

    #Checking if the command is successful and also log the output and error
    if [ $? -eq 0 ]; then
            echo "Successfully removed failed and cleaned data" | tee -a "$logfile"
    else
            echo "Dataset cleaning failed" | tee -a "$logfile"
    fi


**Ensuring the script is executable**

The permission on the preprocess.sh file was seen not to be executable.

Previous output:

    -rw-rw-r-- 1 adeboladesoyin adeboladesoyin 357 Sep 29 23:27 preprocess.sh

The command below was run to give the user an executable permission:

    chmod u+x preprocess.sh

Output:

    -rwxrw-r-- 1 adeboladesoyin adeboladesoyin 357 Sep 29 23:27 preprocess.sh

**Confirming the cleaned_sales_data.csv output**

The commands below were run:

    cd /home/adeboladesoyin/data_pipeline/output
    ls -l
    cat cleaned_sales_data.csv

![alt text](Images/Cleaned_data_commands.png)

## Automating the Pipeline with Cron Jobs

In automating the pipeline, cron job was created to perform the task. The command below was run to launch the cron;

    crontab -e 

It opened the edit tab and the below was scheduled and run;

    # Scheduling the preprocess.sh script to run daily at 12:00 AM

    # For the 5 parameters to be entered in a crontab job, the first one represent minutes, 2nd -hour, 3rd -day in month, 4th - month, and 5th- day in week,
    # I will be using '*' in the fields for others.

    0 0 * * * /home/adeboladesoyin/data_peipeline/input/preprocess.sh

To confirm, if the Cron job is active, the crontab - l  command was run to list the scheduled jobs on the server for my current user. The pgrep cron run would halp us know if the job craeted is active and running by returning process ID.

    crontab -l
    pgrep cron

And here is the output below;

![alt text](Images/Cron_Job.png)
![alt text](Images/CronJoB%20ID.png)

The content in the preprocess.log file

![alt text](Images/logfile.png)

## Logging and Monitoring

It is important to log every output of the job process runs and the errors during run which would aid in monitoring when a process has failed and to optimize performance.

Hence, to monitor the pipeline’s progress. A monitor.sh script was created to check for errors in the preprocess.log file and notify me if any are found.

    touch monitor.sh
    nano monitor.sh

The monitor.sh script searches for any word such as "ERROR" or "failed" using grep command in the log file. If errors are found, it prints it out using echo command.

    #!/bin/bash

    #Searching for the instances of ERROR or failed word in log file

    logfile=/home/adeboladesoyin/data_pipeline/logs/preprocess.log

    Errorsearch=$(grep -Ei 'ERROR|failed' "$logfile")

    #Echoing/returning the lines returned with error or failed
    wordcount=$(echo "$Errorsearch" | wc -l)

    if [ "$wordcount" -gt 0 ]; then
            echo "$wordcount ERROR(s)/Failure(s) found in the preprocess.log file"
    else
            echo "No error or failure found"
    fi

**_Output after run**_

![alt text](Images/Error%20monitoring.png)

**Monitoring script Scheduling**

The monitor.sh script was automated to run by scheduling it to a cron job to run after each daily job processing at exactly 12:05 AM. Crontab -e was run again and the schedule was added as below;

    #preprocess.sh script to run daily at 12:00 AM

    # For the 5 parameters to be entered in a crontab job, the first one represent minutes, 2nd -hour, 3rd -day in month, 4th - month, and 5th- day in week,
    # I will be using '*' in the fields for others.

    0 0 * * * /home/adeboladesoyin/data_pipeline/input/preprocess.sh >> /home/adeboladesoyin/data_pipeline/logs/preprocess.log 2>&1

    #monitor.sh script to run 12:05 AM daily after the preprocess.sh job

    5 0 * * * /home/adeboladesoyin/data_pipeline/logs/monitor.sh

crontab -l was used to list all the cron jobs in the system.

## Permission & Security

Finally, security is paramount as a data engineer to ensure only the required people have the access to the various directories and files. 

**Input folder security**

Before permission

![alt text](Images/Inputdirectory_Prev.png)

The below command was run to ensure only the user can be able to write to the directory.

     chmod go-w input

    ![alt text](Images/Inputdirect_After.png)

**Log folder security**

Read Access to log was restricted for both group and others while the user alone have the read access to the log directory.

     chmod go-r logs

![alt text](Images/LogsReadAccessRestriction.png)


## Conclusion

This project has helped us work and practice on data processing pipeline using Linux commands and bash scripts.

It has helped me to gain deeper understanding on file ingestion, file manipulation, automation of data processings, job orchestration (scheduling with cron) and permission managements to different users, groups or others using chmod symbolic method. 


Thanks for reading through.


