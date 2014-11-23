This script is used to ruun the analysis of Samsung phone data.

Required library: reshape2

=========

The script first checks for the existence of the folder containing the data - UCI HAR Dataset.
If not found, it downloads the dataset.zip, extracts and sets the extracted folder as the new working directory.

1.

The first step is to merge all the required data from the test and training sets, namely:
  - X_test.txt & X_train.txt
  - subject_test.txt & subject_train.txt
  - features.txt (to add colnames)
  - (later I add activity info)
  
2.

I then Extract all data containing calculated mean() or std() in the colnames.

3.

Next I add the activity info to the data and rename the IDs to activity names.
  - I now merge all data into one dataframe
  
4.

The colnames are tidied up to represent more human readable information

5.

Lastly, the data is tidied up using melt() and dcast() functions from the reshape2 library.
  - The final data is written to a file - tidy_data.txt
