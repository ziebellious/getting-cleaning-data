################################################################################
# SCRIPT DETAILS                                                               
#       Filename: RUN_ANALYSIS.R                                                
#       Author:   Rebecca Ziebell (rebecca.ziebell@gmail.com)
#       Purpose:  Generate tidy data set for Coursera Getting and Cleaning Data
#                 course project, due 02/22/2015
################################################################################

#-------------------------------------------------------------------------------
# Set full path to Course Project data.
#-------------------------------------------------------------------------------
path <- paste("C:/Users/Rebecca/Documents/Coursera/Getting and Cleaning Data",
              "Course Project", sep="/"
)

#-------------------------------------------------------------------------------
# Call required packages and set working directory.
#-------------------------------------------------------------------------------
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("reshape2")
library(dplyr)
library(tidyr)
library(reshape2)
setwd(path)

#-------------------------------------------------------------------------------
# Read in subjects, activities, and feature measurement data for both test and
# training groups.
#-------------------------------------------------------------------------------
text_sub <- list(test="./UCI HAR Dataset/test/subject_test.txt",
                 train="./UCI HAR Dataset/train/subject_train.txt"
)
text_act <- list(test="./UCI HAR Dataset/test/y_test.txt",
                 train="./UCI HAR Dataset/train/y_train.txt"
)
text_fea <- list(test="./UCI HAR Dataset/test/X_test.txt",
                 train="./UCI HAR Dataset/train/X_train.txt"
)
read_sub <- lapply(text_sub, read.table, col.names=c("sub_id"))
read_act <- lapply(text_act,read.table, col.names=c("act_id"))
read_fea <- lapply(text_fea, read.table)
rm("text_sub", "text_act", "text_fea")

#-------------------------------------------------------------------------------
# Combine subjects, activities, and feature measurement data. Read in activity
# labels and add to measurement data.
#-------------------------------------------------------------------------------
combine <- function(x) {
        x <- vector("list", length(read_fea))
        names(x) <- names(read_fea)
        for (i in seq_along(read_fea)) {
                x[[i]] <- cbind(read_sub[[i]], read_act[[i]], read_fea[[i]])
        }
        x
}
sub_act_fea <- combine()
act_labels <- read.table("./UCI HAR Dataset/activity_labels.txt",
                         col.names=c("act_id", "act_label")
)
act_labels$act_label <- gsub("_", " ", act_labels$act_label)
sub_act_fea <- lapply(sub_act_fea, merge, y=act_labels, by.x="act_id",
                      by.y="act_id", all
)
rm("read_sub", "read_act", "read_fea", "combine", "act_labels")

#-------------------------------------------------------------------------------
# Read in feature IDs/labels, converting labels from factor to character vector.
# Keep features that include "mean()" or "std()". Create V-prefixed version of 
# feature ID for use in selecting desired measurements for subject activities.
#-------------------------------------------------------------------------------
ft_labels <- read.table("./UCI HAR Dataset/features.txt",
                        col.names=c("ft_id", "ft_label")
)
ft_labels$ft_label <- as.character(ft_labels$ft_label)
ft_sel <- filter(ft_labels, grepl('mean\\(\\)', ft_label) == TRUE
                 | grepl('std\\(\\)', ft_label) == TRUE
)
ft_sel$ft_varnum <- paste("V", ft_sel$ft_id, sep="")
ft_sel <- select(ft_sel, -ft_id)
saf_sel <- lapply(seq_along(sub_act_fea),
                  function(i, x) {
                          df <- x[[i]]
                          df <- df[, c("sub_id", "act_label", ft_sel$ft_varnum)]
                          x[[i]] <- df
                  },
                  sub_act_fea
)
names(saf_sel) <- names(sub_act_fea)
rm("ft_labels", "sub_act_fea")

#-------------------------------------------------------------------------------
# Transpose feature columns to rows. Add feature labels and column names. Sort
# by subject ID, activity label, and feature number. Keep only needed variables.
# Assign meaningful column names.
#-------------------------------------------------------------------------------
saf_trans <- lapply(saf_sel, melt, c("sub_id", "act_label"),
                    variable.name="ft_varnum", value.name="measure"
)
names(saf_trans) <- names(saf_sel)
saf_trans <- lapply(saf_trans, merge, ft_sel, by.x="ft_varnum", 
                    by.y="ft_varnum", all
)
saf_trans <- lapply(saf_trans, arrange, sub_id, act_label, ft_varnum)
saf_trans <- lapply(saf_trans, select, sub_id, act_label, ft_label, measure)
saf_trans <- lapply(saf_trans, rename, Subject=sub_id, Activity=act_label,
                    Feature=ft_label, Measurement=measure
)
rm("saf_sel", "ft_sel")

#-------------------------------------------------------------------------------
# Combine test and training data. Average measurements across all windows for
# each subject, activity, and feature.
#-------------------------------------------------------------------------------
test_train <- rbind(saf_trans$test, saf_trans$train)
avg_mean_std <- test_train %>%
        group_by(Subject, Activity, Feature) %>%
        summarize(AvgMeasurement = mean(Measurement, na.rm=TRUE))

#-------------------------------------------------------------------------------
# Write out to flat text file.
#-------------------------------------------------------------------------------
if (file.exists(paste(path, "tidy_final.txt", sep="/"))) {
        file.remove(paste(path, "tidy_final.txt", sep="/"))
        "File removed"
}
write.table(avg_mean_std, file=paste(path, "tidy_final.txt", sep="/"),
            row.names=FALSE
)
rm("saf_trans", "test_train", "avg_mean_std", "path")

################################################################################
# END OF SCRIPT
################################################################################
