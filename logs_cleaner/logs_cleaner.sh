#!/bin/bash

# This script deletes log files that are older than a specified number of days.

# Define a function to print the usage of the script
usage() {
  # prints the usage of the script
  echo "Usage: $0 [-d <log_directory>] [-n <days_to_keep>]"
  exit 1  # exits the script with a status of 1
}

# Parse command-line options using getopts
# start of the while loop which will iterate through all the options passed
while getopts ":d:n:" opt; do
  case $opt in

    # If the -d option is used, set the value of LOG_DIR to the argument of the
    # option
    d)
      # assigns the argument of the -d option to the LOG_DIR variable
      LOG_DIR=$OPTARG
      ;;

    # If the -n option is used, set the value of DAYS_TO_KEEP to the argument
    # of the option
    n)
      # assigns the argument of the -n option to the DAYS_TO_KEEP variable
      DAYS_TO_KEEP=$OPTARG
      ;;

    # If an invalid option is used, print an error message and the usage of
    # the script
    \?)
      echo "Invalid option: -$OPTARG" >&2  # prints an error message
      usage  # calls the usage function
      ;;

    # If an option requires an argument but none is provided, print an error
    # message and the usage of the script
    :)
      # prints an error message
      echo "Option -$OPTARG requires an argument." >&2
      usage  # calls the usage function
      ;;

  esac  # ends the case statement
done   # ends the while loop

# Check if required arguments were provided
# checks if the LOG_DIR and DAYS_TO_KEEP variables are empty
if [ -z "$LOG_DIR" ] || [ -z "$DAYS_TO_KEEP" ]; then
  usage  # calls the usage function if any of the variables are empty
fi

# Check if the specified directory exists
if [ ! -d "$LOG_DIR" ]; then  # checks if the LOG_DIR directory does not exist
  echo "Error: directory $LOG_DIR does not exist."
  usage
fi

# Check if the specified number of days is a valid number
if ! [[ "$DAYS_TO_KEEP" =~ ^[0-9]+$ ]]; then
  echo "Error: days to keep must be a positive integer."
  usage
fi

# Search for all log files that have "*.log*" in their names
if [ $DAYS_TO_KEEP -eq 0 ]; then
  # Delete all log files if the number of days is 0
  log_files=$(find "$LOG_DIR" -type f -name "*.log*")
else
  log_files=$(find "$LOG_DIR" -type f -name "*.log*" -mtime +$DAYS_TO_KEEP)
fi

# Initialize the total size saved and the number of files deleted variables
TOTAL_SIZE_SAVED=0
NUM_FILES_DELETED=0

for log_file in $log_files; do

  # Check if the file exists
  if [ -e "$log_file" ]; then

    # Get the size of the file
    file_size=$(du -k "$log_file" | cut -f1)

    # Add the file size to the total size saved
    TOTAL_SIZE_SAVED=$((TOTAL_SIZE_SAVED + $file_size))

    # Delete the file
    rm "$log_file"

    # Increment the number of files deleted
    NUM_FILES_DELETED=$((NUM_FILES_DELETED + 1))

    # Print a message indicating that the file was deleted and its size
    echo "Deleted file: $log_file, Size: $file_size KB"
  else
    # Print a message indicating that the file could not be found
    echo "Could not find file: $log_file"
  fi
done

# calculate the total size saved
if (( $(echo "$TOTAL_SIZE_SAVED < 1024" | bc -l) )); then
  echo "Total size saved: $TOTAL_SIZE_SAVED KB by deleting ${NUM_FILES_DELETED} files."
else
  TOTAL_SIZE_SAVED_MB=$(echo "scale=2; $TOTAL_SIZE_SAVED / 1024" | bc -l)
  echo "Total size saved: $TOTAL_SIZE_SAVED_MB MB by deleting ${NUM_FILES_DELETED} files."
fi