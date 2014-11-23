library(reshape2)

##### Download Data Files & Extract From Archive If The UCI Directory Doesn't Already Exist #####

# I look for the existance of the phone data directory - if not present, download & extract
if(!file.exists("UCI\ HAR\ Dataset")) {
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, dest="./dataset.zip", method="curl")
        unzip("./dataset.zip")
}
# Set this as my working directory
setwd("./UCI\ HAR\ Dataset")

##### 1. Merge Test & Training Data #####

# get the data files required for this analysis - initially x_test & x_train. 
# .. later I add the activities & subjects
test_data <- read.table("./test/X_test.txt")    # test data
train_data <- read.table("./train/X_train.txt") # training data
features <- read.table("./features.txt")        # use features.txt file to get colnames
cols <- as.data.frame(features$V2)              # assign df to column 2 of features file
cols <- t(cols)                                 # transpose names into column names

merged_data <- rbind(test_data,train_data)      # rbind test & training data into one
colnames(merged_data) <- cols                   # assign colnames from cols

# get subject data 
test_subjects <- read.table("./test/subject_test.txt")
train_subjects <- read.table("./train/subject_train.txt")
merged_subjects <- rbind(test_subjects,train_subjects)
colnames(merged_subjects) <- c("Subject")


##### 2. Extract Mean & SD #####

# I'm using grep to weed out all data with colnames containing either 'mean()' or 'std()'.
merged_data <- merged_data[grep("mean\\(\\)|std\\(\\)",names(merged_data))]


##### 3. Add Descriptive Activity Names #####

# first get the files associated with activity
test_acts <- read.table("./test/y_test.txt")            # test activity ids
train_acts <- read.table("./train/y_train.txt")         # training activity ids
act_names <- read.table("./activity_labels.txt")        # ids2names file
merged_activities <- rbind(test_acts,train_acts)        # merge both id sets
colnames(merged_activities) <- c("Activity")            # Assign a colname

# Use factor to relabel Activity IDs into Names using the act_names df from above 
merged_data$Activity <- factor(merged_data$Activity, levels=act_names$V1, labels=act_names$V2)

# Now, I finally merge all 3 components (data, activity & subject) into one DF.
merged_data <- cbind(merged_data,merged_activities,merged_subjects)


##### 4. Label Dataset With Descriptive Variable Names #####

new_cols <- gsub("^f(.*?)", "FrequencyOf\\1", names(merged_data)) # replace 'f' at start of name with full desciption
new_cols <- gsub("^t(.*?)", "TimeOf\\1", new_cols)      # same with 't'
new_cols <- gsub("[\\(\\)\\-]", "", new_cols)           # remove all unwanted characters "()-"
new_cols <- gsub("BodyBody", "Body", new_cols)          # replace duplicate entries
new_cols <- gsub("mean", "Mean", new_cols)              # .. general 
new_cols <- gsub("std", "StandardDeviation", new_cols)  # .. tidying
new_cols <- gsub("Acc", "Acceleration", new_cols)       # .. up 
new_cols <- gsub("Mag", "Magnitude", new_cols)          # .. of
new_cols <- gsub("Gyro", "Gyroscope", new_cols)         # .. names
new_cols <- gsub("([XYZ])", "ForThe\\1Axis", new_cols)  # Give the axes some literal description
new_cols <- gsub("([A-Z])", " \\1", new_cols)           # Finally place a space before uppercase letters
new_cols <- gsub("^\\s+|\\s+$", "", new_cols)           # Remove leading & trailing whitespace
colnames(merged_data) <- new_cols                       # Assign new changes to the colnames


##### 5. Tidy Data #####

# I'm using the melt & dcast functions from the reshape2 library to tidy by Subject and Activity.
melt_data <- melt(merged_data, id.vars=c("Subject","Activity"))
tidy <- dcast(melt_data, Subject + Activity ~ variable, fun = mean)

# Finally write out the finished table - woohoo!!
write.table(tidy, file="./tidy_data.txt", row.names=FALSE)
