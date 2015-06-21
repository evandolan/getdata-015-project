## Coursera - Getting and Cleaning Data
## Week 3
## Course Project
## Evan Dolan

# Setup


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
head(experiments)


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
# Need get_descriptive_variable_names func here
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

# Returns the column name without the method and axis
remove_tail <- function(col_name) {
    endIndex <- gregexpr(col_name, pattern = "-")[[1]][1]
    substring(col_name, 1, endIndex-1)
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

names(subject_df)
split_by_activity <- split(subject_df, subject_df[(length(subject_df))])
sub1_means <- sapply(split_by_activity, function(x) { colMeans(x[1:(length(x)-2)]) })

solve(sub1_means)
?melt

acitivty_df <- as.data.frame(split_by_activity[1])
dim(acitivty_df)
colMeans(acitivty_df[1:(length(acitivty_df)-2)])
lapply(acitivty_df[1:(length(acitivty_df)-2)], colMeans)
dim(acitivty_df[1:(length(acitivty_df)-2)])
#


tapply(subject_df, subject_df[length(subject_df)], function(x) { colMeans(x[1:(length(x)-2)]) })

dim(subject_df[1:(length(subject_df)-2)])


as.data.frame(split_by_subject[2])$X2.activity
split_by_subject_and_activity <- split(split_by_subject, split_by_subject$)
?tapply
names(experiments_mean_std)
colMeans(experiments_mean_std[1:(length(experiments_mean_std)-2)])
