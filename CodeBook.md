# getdata-015-project
This document describes the variables, the data, and any transformations carried out during this project.
This document will describe the code in the run_analysis.R, separated intwo five sections as outlined by the project description.

1. Merges the training and the test sets to create one data set.
----------------------------------------------------------------
First, read in the list of all features and the activity names to 'features' and 'activity_labels', respectively.
Update the column names in 'activity_labels' to something more descriptive.
Read in the test data. Ordered list of subject numbers into 'subject_test'.
List of values of data from the smart phone into 'X_test'. List of the activities 
that the subject was carrying out during the test, into 'y_test'. Updated 
the column names in the ''X_test' variable to the correct names (from 
the 'features' variable). Add the activity numbers and subject numbers 
to the 'X_test' variable.
The exact same process is carried out for the train data (lines 37 - 45).

Merge both the test data and the train data using the rbind function into the
'experiments' variable. This is carried out on line 48.

2. Extracts only the measurements on the mean and standard deviation for each measurement.
------------------------------------------------------------------------------------------
Get the column names from 'experiments' and store in the 'experiments_col_names' variable.
Get a True/False list of the columns that contain either "mean" or "std". Store this in 
the 'cols_with_mean_and_std' variable. Subset the column names that contain either "mean" or 
"std" into the variable 'experiments_col_names_mean_std'. Remove the columns that contain 
"meanFreq" by finding the location of the column names with "meanFreq" (stored in
'cols_without_meanFreq') and then subset this to create the 'experiments_col_names_final' 
variable. Add the column names "activity_number" and "subject" to this variable.

Create a new variable called 'experiments_mean_std' which contains all of the observations 
for the experiments but only the values for the mean and standard deviation of each measurement 
and also the activity number and subject.


3. Uses descriptive activity names to name the activities in the data set.
----------------------------------------------------------------------------
Connect the activity labels with the 'experiments_mean_std' variable using the join function from 
the plyr package. This is will add an extra column to the 'experiments_mean_std' variable 
to represent the activities. The join function will add the correct activity to each row 
based on the activity_number in each row.

The activity_number column is no longer needed in the 'experiments_mean_std' variable 
so set it to NULL on line 80 to remove it.

4. Appropriately labels the data set with descriptive variable names.
-----------------------------------------------------------------------
Get the column names of the dataset and store in the 'col_names' variable.
Create the 'get_descriptive_variable_names' function on lines 89 - 96. This function iterates through 
a list of column names and returns a list of more descriptive column names.
Create the 'time_or_freq' function on lines 99 - 107. This function takes a string and returns "time_" 
if the parameter begins with "t", otherwise "frequency_" is returned. This function is used for 
creating descriptive variable names.
Create the "full_names" function on line 110 - 115. This function replaces some short-hand terms 
and replaces them with the full spelling of the word.
Create the "fix_methods_and_axis" function on lines 118 - 127. This function replaces some short-hand 
terms for describing common words in the column names with the full spelling of the word.
Create the "parse_descriptive_name" function. This function uses all of the other "descriptive variable 
names" functions and parses the column names. It returns a descriptive version of the column name 
supplied to it.
Get the descriptive variable names for the column names in the dataset (excluding "subject" and  "activity").
Add the column names "subject" and "activity" to the list of descriptive column names.
Update the column names of the "experiments_mean_std" variable to the descriptive version on line 156.

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
-------------------------------------------------------------------------------------------------------------------------------------------------
My approach for this section was to split the dataset containing all of the observations by subject and then
by activity. The function "get_average_for_activities" takes a data frame containing all observations for a particular subject 
and returns a data frame with the averages for each variable for each activity.

I did not finished the next part. The function "get_average_values" attempts to split a dataset by the subject value 
and then call the "get_average_for_activities" function to get the values for each activity for each subject.
I did not finish this function. I believe I am close but I ran out of time.

You could manual split the data set (using the built in split function) and pass each of those
datasets to the "get_average_for_activities" function and you would have all the output required.