library(data.table)
library(dplyr)

packageVersion("data.table")
packageVersion("dplyr")

setwd("/home/jambo/developments/DataScience/tidydatawearable/scripts/")

#Download data and uncompress
if(!file.exists("./data")){
    dir.create("./data")
}
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, destfile = "./data/UCI_HAR_Dataset.zip", method="curl")

unzip(zipfile="./data/UCI_HAR_Dataset.zip", exdir="./data")

#List of files
path <- file.path("./data/UCI HAR Dataset")
files <- list.files(path , recursive = TRUE)
files

###1. Merges the training and the test sets to create one data set.
#Reading Metadata
#Activity
data_train_Y <- read.table(file.path(path, "train", "y_train.txt"),header = FALSE)
data_test_Y  <- read.table(file.path(path, "test" , "y_test.txt" ),header = FALSE)
#Features
data_test_X  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
data_train_X <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)
#Subject
data_test_subject  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
data_train_subject <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)

#Read features names
featuresNames <- read.table(file.path(path, "features.txt"),head=FALSE)

#Merge dataframes
activity <- rbind(data_test_Y, data_train_Y)
feature <- rbind(data_test_X, data_train_X)
subject <- rbind(data_test_subject, data_train_subject)

#Rename dataframes
names(activity) <- c("activityID")
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
names(activityLabels) <- c("activityID", "activity")
###3. Uses descriptive activity names to name the activities in the data set
activityFactor <- left_join(activity, activityLabels, "activityID")

names(subject) <- c("subject")
names(feature) <- featuresNames$V2

#merging data frames
dataActivitySubject <- cbind(activityFactor, subject)
allData <- cbind(dataActivitySubject, feature)

#Have a glance on allData
View(head(allData))

###2. Extracts only the measurements on the mean and standard deviation for each measurement.
subdataFeatures <- featuresNames$V2[grep("mean\\(\\)|sub\\(\\)",featuresNames$V2)]
DataNames <- c("subject", "activity", as.character(subdataFeatures))
DataSet <- allData[DataNames]

###4. Appropriately labels the data set with descriptive variable names.
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("Body", "Body", names(DataSet))

###5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
subData2 <- aggregate(. ~subject + activity, data = DataSet, mean)
subData2 <- subData2[order(subData2$subject,subData2$activity),]

write.table(subData2, file = "tidydata.txt",row.name=FALSE)
