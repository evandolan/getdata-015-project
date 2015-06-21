## Coursera - Getting and Cleaning Data
## Week 3
## Course Project
## Evan Dolan

# Setup
setwd("C:/Users/tina/Documents/Coursera/gettingdata/UCI HAR Dataset")

# Load packages
install.packages("plyr")
install.packages("dplyr")
library(plyr)
library(dplyr)


## Step 1
#   Merges the training and the test sets to create one data set.

## Read labels
features <- read.table("features.txt", sep = " ")
activity_labels <- read.table("activity_labels.txt")
# Change column names in activity_labels dataset
names(activity_labels) <- c("activity_number", "activity")

## Read test data
subject_test <- read.table("test/subject_test.txt")
X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
# Add column names to test data
names(X_test) <- features$V2

## Add activity label & subject number to test data
X_test[, "activity_number"] <- y_test
X_test[, "subject"] <- subject_test

## Read training data
subject_train <- read.table("train/subject_train.txt")
X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
# Add column names to training data
names(X_train) <- features$V2

## Add activity label & subject number to training data
X_train[, "activity_number"] <- y_train
X_train[, "subject"] <- subject_train

## Merge the training and test sets into one data set
experiments <- rbind(X_train, X_test)


## Step 2
#   Extracts only the measurements on the mean and standard deviation for each measurement.
# Get all column names in experiements data set
experiments_col_names <- names(experiments)

# Get a True/False list of column names containg 'mean' or 'std' (for standard deviation)
cols_with_mean_and_std <- grepl("mean", experiments_col_names) | grepl("std", experiments_col_names)

# Get column names that contain 'mean' or 'std'
experiments_col_names_mean_std <- names(experiments[, cols_with_mean_and_std])

# Remove columns contain 'meanFreq'
# Get True/False list of column names without meanFreq
cols_without_meanFreq <- !grepl("meanFreq", experiments_col_names_mean_std)

# Get column names that contain 'mean' or 'std' and not 'meanFreq'
experiments_col_names_final <- experiments_col_names_mean_std[cols_without_meanFreq]

experiments_col_names_final <- c(experiments_col_names_final, "activity_number", "subject")

# Create a new dataset containing the mean and std columns as well as the activity_number and subject
experiments_mean_std <- experiments[, experiments_col_names_final]


## Step 3
#   Uses descriptive activity names to name the activities in the data set
# Join activity labels to experiments dataset based on activity numbers
experiments_mean_std <- join(experiments_mean_std, activity_labels)
# Remove activity_number column, no longer needed
experiments_mean_std$activity_number <- NULL


## Step 4
#   Appropriately labels the data set with descriptive variable names. 
# Get the column names from the dataset
col_names <- names(experiments_mean_std)

# Interates through a list of column names and returns the descriptive variable name for each
get_descriptive_variable_names <- function(cols) {
    col_list <- character()
    for(i in 1:length(cols)) {
        col_list <- c(col_list, parse_descriptive_name(cols[i]))
    }
    
    col_list
}

# Returns 'time' if the column name starts with 't'. Otherwise, returns 'frequency'
time_or_freq <- function(col_name) {
    if(substring(col_name,1,1) == "t") {
        fixed <-  "time_"
    } else {
        fixed <- "frequency_"
    }
    
    fixed 
}

# Returns the column name using the full names for Acc, Gyro, and Mag
full_names <- function(col_name) {
    col_name <- gsub("Acc", "Accelerometer", col_name)
    col_name <- gsub("Gyro", "Gyroscope", col_name)
    col_name <- gsub("Mag", "Magnitude", col_name)
    col_name
}

# Returns the descriptive name for the method and axis
fix_methods_and_axis <- function(col_name) {
    # Replace the method names
    col_name <- gsub("-std()", "_StandardDeviation", col_name)
    col_name <- gsub("-mean()", "_Mean", col_name)
    # Replace the axis names
    col_name <- gsub("-X", "_X-axis", col_name)
    col_name <- gsub("-Y", "_Y-axis", col_name)
    col_name <- gsub("-Z", "_Z-axis", col_name)
    col_name
}

# Takes a column name and returns the a descriptive variable name
parse_descriptive_name <- function(col_name) {
    # Parse the first character for either 'time' or 'frequency'
    fixed_col_name <- time_or_freq(col_name)
    
    # Trim first char from string
    col_name <- substring(col_name, 2, nchar(col_name))
    
    # Add 'time' or 'frequency' to column name
    fixed_col_name <- paste(fixed_col_name, col_name, sep="")
    
    # Get full names for shortened words
    fixed_col_name <- full_names(fixed_col_name)
    
    # Get descriptive method & axis
    fixed_col_name <- fix_methods_and_axis(fixed_col_name)
    
    fixed_col_name
}

# Get descriptive variable names (remove 'subject' and 'activity' since they're already descriptive)
descriptive_col_names <- get_descriptive_variable_names(col_names[1:(length(col_names)-2)])

# Add subject and activity variable names to the list of descriptive variable names
descriptive_col_names <- c(descriptive_col_names, c("subject", "activity"))

# Change the variable anmes of the data set to the descriptive variable names
names(experiments_mean_std) <- descriptive_col_names


## Step 5
#   From the data set in step 4, creates a second, independent tidy data set with the average
#   of each variable for each activity and each subject.
split_by_subject <- split(experiments_mean_std, experiments_mean_std$subject)
subject_df <- as.data.frame(split_by_subject[1])
colnames(subject_df)[length(colnames(subject_df))] <- "activity"
split_by_act <- split(subject_df, subject_df$activity)
activity_df <- as.data.frame(split_by_act[1])
laying <- colMeans(activity_df[,1:(length(activity_df)-2)])

activity_df2 <- as.data.frame(split_by_act[2])
sitting <- colMeans(activity_df2[, 1:(length(activity_df2)-2)])

lay_sit <- rbind(laying, sitting)

get_average_for_activities <- function(subject_df, subject_number) {
    avgs_df <- data.frame()
    
    # Change name of last column to be "activity"
    colnames(subject_df)[length(colnames(subject_df))] <- "activity"
    
    # Split the data frame for the subject by activity
    split_by_act <- split(subject_df, subject_df$activity)
    
    # Iterate through the list and calculate averages of each variable for each activity
    for(i in 1:length(split_by_act)) {
        # Add means to the avgs_df data frame
        #avgs_df <- cbind(avgs_df, as.data.frame(split_by_act[i])[68][,1])
        activity_values <- as.data.frame(split_by_act[subject_number])
        col_means_for_activity <- colMeans(activity_values[, 1:(length(activity_values)-2)])
        col_means_for_activity <- as.data.frame(col_means_for_activity)
        # Add value for the subject column
        col_means_for_activity$subject <- 1
          
        # Add the average values for this activity to the data frame
        avgs_df <- rbind(avgs_df, col_means_for_activity)
    }
    
    avgs_df
}


get_average_values <- function(experiments_df) {
    all_avg_values <- data.frame()
    
    # Split the dataset by subject numbers
    split_by_subject <- split(experiments_df, experiments_df$subject)
    print(length(split_by_subject))
    # Iterate through the list of subjects and get the average values
    for(j in 1:length(split_by_subject)) {
        # Convert the subject into a data frame
        subject_df <- as.data.frame(split_by_subject[j])
        
        # Get averages for all activitys for current subject
        activity_df <- get_average_for_activities(subject_df, j)
        all_avg_values <- rbind(all_avg_values, activity_df)
    }
    
    all_avg_values
}