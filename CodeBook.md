# Code book for tidy_final.txt
***
##Contents
Tidy_final.txt is a flat file that contains 11,880 observations in 4 variables. It contains a header row and can be read into R as follows:
```r
tidy_final <- read.table("tidy_final.txt", header=TRUE)
```
The variables are:
<table>
  <thead>
    <tr width="100%">
      <td width="15%"><b>Name</b></td>
      <td width="15%"><b>Class</b></td>
      <td width="70%"><b>Description</b></td>
    </tr>
  </thead>
  <tbody>
    <tr width="100%">
      <td width="15%">Subject</td>
      <td width="15%">integer</td>
      <td width="70%">Person-level identifier</td>
    </tr>
    <tr width="100%">
      <td width="15%">Activity</td>
      <td width="15%">factor</td>
      <td width="70%">Type of activity. Six possible values: LAYING, SITTING, STANDING, WALKING, WALKING DOWNSTAIRS, WALKING UPSTAIRS.</td>
    </tr>
    <tr width="100%">
      <td width="15%">Feature</td>
      <td width="15%">factor</td>
      <td width="70%">Type of feature and associated measurement (either mean or standard deviation). Additional information available in the features_info.txt file from the <a href="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip">UCI HAR Dataset</a>.</td>
    </tr>
    <tr width="100%">
      <td width="15%">AvgMeasurement</td>
      <td width="15%">numeric</td>
      <td width="70%">Average of measurements across all sample windows for each combination of subject, activity, and feature.</td>
    </tr>
  </tbody>
</table>
  </tbody>
</table>

##Creation
Tidy_final.txt was created in R using the script run_analysis.R, which runs against data from the [UCI HAR Dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). These data must be stored in a folder called "UCI HAR Dataset" within the R working directory. The script involves the following steps (which are explained in more detail via comments throughout the script):
+ Call required packages: dplyr, tidyr, and reshape2.
+ Read in subjects, activities, and feature measurement data for both test and training sets (stored in a list).
+ Combine subject, activity, and feature measurement data for both test and training sets.  
+ Read in activity labels and add to combined data described in \#3 above.
+ Read in feature IDs and labels, keeping feature labels that include the string "mean()" or "std()". 
+ In combined measurement data, transpose feature columns to rows.
+ Add feature labels and column names to transposed data.
+ Merge transposed data with feature label data (described in \#5 above) to limit combined data to only the desired measurements for each feature.
+ Assign meaningful column names.
+ Combine test and training data from list into single data frame.
+ Average measurements across all sample windows for each subject, activity, and feature.
+ Write R data frame to tidy_final.txt.
