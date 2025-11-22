install.packages(c("readxl", "dplyr" , "tidyr"))
library(readxl)
library(dplyr)

# Define the file path
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV_Test.xlsx"

library(dplyr)
library(tidyr)

# Load the data (update file path if necessary)
library(readxl)
df <- read_excel("/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV_Test.xlsx", skip = 2) 
# Skip first 3 rows since column names start from row 3

# View column names to confirm
print(colnames(df))

# Select columns for each media type
video_columns <- df %>% select(`Correct...6`, `Correct...14`, `Correct...22`, `Correct...30`)
image_columns <- df %>% select(`Correct...38`, `Correct...46`, `Correct...54`, `Correct...62`)
text_columns  <- df %>% select(`Correct...70`, `Correct...78`, `Correct...86`, `Correct...94`)

# Calculate accuracy per media type (percentage of correct answers)
df$Video_Accuracy <- rowMeans(video_columns, na.rm = TRUE)
df$Image_Accuracy <- rowMeans(image_columns, na.rm = TRUE)
df$Text_Accuracy  <- rowMeans(text_columns, na.rm = TRUE)

# Calculate overall accuracy
df$Overall_Accuracy <- rowMeans(df %>% select(Video_Accuracy, Image_Accuracy, Text_Accuracy), na.rm = TRUE)

# Check results
head(df %>% select(Video_Accuracy, Image_Accuracy, Text_Accuracy, Overall_Accuracy))

summary(correct_columns)
summary(df$Overall_Accuracy)  
summary(df %>% select(contains("Correct")))

#BINOMIAL TEST TO UNDERSTAND IF OVERALL ACCURACY IS SIGNIFICANT
# Now we perform the Binomial test:
# Calculate the total number of correct answers (sum of all 1's in Overall_Accuracy)
correct_answers = sum(df$Overall_Accuracy * 12)  # Multiply Overall_Accuracy by 12 to get the number of correct answers for each participant

# Total number of trials (12 questions per participant, and n participants)
total_trials = 12 * nrow(df)

# Perform binomial test: testing if the proportion of correct answers differs from 50%
binom_result <- binom.test(correct_answers, total_trials, p = 0.5, alternative = "two.sided")

# View the result of the binomial test
binom_result


# THE DIFFERENCE BETWEEN MEDIA TYPES

# Calculate total correct answers for each media type
video_correct <- sum(df$Video_Accuracy * 4)  # Each participant answered 4 video questions
image_correct <- sum(df$Image_Accuracy * 4)  # Each participant answered 4 image questions
text_correct  <- sum(df$Text_Accuracy * 4)   # Each participant answered 4 text questions

# Total number of trials per media type (4 questions per participant)
total_trials_per_media <- 4 * nrow(df)

# Binomial test for Video
video_binom <- binom.test(video_correct, total_trials_per_media, p = 0.5, alternative = "two.sided")

# Binomial test for Image
image_binom <- binom.test(image_correct, total_trials_per_media, p = 0.5, alternative = "two.sided")

# Binomial test for Text
text_binom  <- binom.test(text_correct, total_trials_per_media, p = 0.5, alternative = "two.sided")

# View results
video_binom
image_binom
text_binom

# Create a contingency table for correct answers across media types
media_accuracy_table <- matrix(c(video_correct, image_correct, text_correct, 
                                 total_trials_per_media - video_correct, 
                                 total_trials_per_media - image_correct, 
                                 total_trials_per_media - text_correct), 
                               nrow = 3, byrow = TRUE)

# Perform Chi-Square test
media_chi_square <- chisq.test(media_accuracy_table)

# View result
media_chi_square


# COMPARING EACH MEDIA TYPE WITH TOTAL ACCURACY
# Total number of correct answers (all media types combined)
total_correct <- sum(df$Overall_Accuracy * 12)  # Since each participant answered 12 questions
total_trials <- 12 * nrow(df)  # Total number of trials

# Binomial tests comparing each media type to overall accuracy
video_vs_total <- binom.test(video_correct, total_trials_per_media, 
                             p = total_correct / total_trials, alternative = "two.sided")

image_vs_total <- binom.test(image_correct, total_trials_per_media, 
                             p = total_correct / total_trials, alternative = "two.sided")

text_vs_total <- binom.test(text_correct, total_trials_per_media, 
                            p = total_correct / total_trials, alternative = "two.sided")

# View results
video_vs_total
image_vs_total
text_vs_total


# PERCEPTION CHECK
# Install necessary packages if not already installed
install.packages(c("lme4", "lmerTest", "ggplot2"))

# Load libraries
library(lme4)       
library(lmerTest)  
library(dplyr)      
library(ggplot2)    
library(readxl)    
library(tidyr)      

# Load the dataset (Skipping first 2 rows)
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data.xlsx"
data <- read_excel(file_path, skip = 2)  

# Convert categorical variables to factors
data <- data %>%
  mutate(Age = as.factor(Age),
         Education = as.factor(Education),
         Occupation = as.factor(Occupation))

# Gather all Perception and Content Source columns into long format
perception_cols <- grep("Perception...", colnames(data), value = TRUE)
content_source_cols <- grep("Content Source...", colnames(data), value = TRUE)
quality_cols <- grep("Quality", colnames(data), value = TRUE)
trustworthiness_cols <- grep("Trustworthiness", colnames(data), value = TRUE)
engagement_cols <- grep("Engagement", colnames(data), value = TRUE)

# Load necessary libraries
library(dplyr)
library(tidyr)

# Define column groups
perception_cols <- c("Perception...9", "Perception...17", "Perception...25", "Perception...33",
                     "Perception...41", "Perception...49", "Perception...57", "Perception...65",
                     "Perception...73", "Perception...81", "Perception...89", "Perception...97")

content_source_cols <- c("Content Source...8", "Content Source...16", "Content Source...24", "Content Source...32",
                         "Content Source...40", "Content Source...48", "Content Source...56", "Content Source...64",
                         "Content Source...72", "Content Source...80", "Content Source...88", "Content Source...96")

quality_cols <- c("Video 1 Quality", "Video 2 Quality", "Video 3 Quality", "Video 4 Quality",
                  "Image 1 Quality", "Image 2 Quality", "Image 3 Quality", "Image 4 Quality",
                  "Text 1 Quality", "Text 2 Quality", "Text 3 Quality", "Text 4 Quality")

trustworthiness_cols <- c("Video 1 Trustworthiness", "Video 2 Trustworthiness", "Video 3 Trustworthiness", "Video 4 Trustworthiness",
                          "Image 1 Trustworthiness", "Image 2 Trustworthiness", "Image 3 Trustworthiness", "Image 4 Trustworthiness",
                          "Text 1 Trustworthiness", "Text 2 Trustworthiness", "Text 3 Trustworthiness", "Text 4 Trustworthiness")

engagement_cols <- c("Video 1 Engagement", "Video 2 Engagement", "Video 3 Engagement", "Video 4 Engagement",
                     "Image 1 Engagement", "Image 2 Engagement", "Image 3 Engagement", "Image 4 Engagement",
                     "Text 1 Engagement", "Text 2 Engagement", "Text 3 Engagement", "Text 4 Engagement")

# Assuming df is your data frame and quality_cols contains the names of the columns you want to test
quality_cols <- c("Video 1 Quality", "Video 2 Quality", "Video 3 Quality", "Video 4 Quality",
                  "Image 1 Quality", "Image 2 Quality", "Image 3 Quality", "Image 4 Quality",
                  "Text 1 Quality", "Text 2 Quality", "Text 3 Quality", "Text 4 Quality")

# Loop through each column and check normality
for (col in quality_cols) {
  # Histogram
  hist(df[[col]], main=paste("Histogram of", col), xlab=col, col="lightblue", border="black")
  
  # Q-Q plot
  qqnorm(df[[col]])
  qqline(df[[col]], col="red")
  
  # Shapiro-Wilk Test
  shapiro_result <- shapiro.test(df[[col]])
  print(paste("Shapiro-Wilk test p-value for", col, ":", shapiro_result$p.value))
}

for (col in trustworthiness_cols) {
  # Histogram
  hist(df[[col]], main=paste("Histogram of", col), xlab=col, col="lightblue", border="black")
  
  # Q-Q plot
  qqnorm(df[[col]])
  qqline(df[[col]], col="red")
  
  # Shapiro-Wilk Test
  shapiro_result <- shapiro.test(df[[col]])
  print(paste("Shapiro-Wilk test p-value for", col, ":", shapiro_result$p.value))
}

for (col in engagement_cols) {
  # Histogram
  hist(df[[col]], main=paste("Histogram of", col), xlab=col, col="lightblue", border="black")
  
  # Q-Q plot
  qqnorm(df[[col]])
  qqline(df[[col]], col="red")
  
  # Shapiro-Wilk Test
  shapiro_result <- shapiro.test(df[[col]])
  print(paste("Shapiro-Wilk test p-value for", col, ":", shapiro_result$p.value))
}



# Load necessary libraries
library(readxl)   # For reading Excel files
library(dplyr)    # For data manipulation

#QUALITY vs PERCEPTION

# Define the file path
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV_Test.xlsx"

# Load the data from the "Perception" sheet
data <- read_excel(file_path, sheet = "Perception")

# Check the first few rows of the data to understand its structure
head(data)



# Subset the data for AI and Human Perception
AI_data <- data %>% filter(Perception == "AI")
Human_data <- data %>% filter(Perception == "Human")

# Check the number of AI and Human values
AI_count <- nrow(AI_data)
Human_count <- nrow(Human_data)

# Calculate the means of Quality for AI and Human
AI_mean <- mean(AI_data$Quality, na.rm = TRUE)
Human_mean <- mean(Human_data$Quality, na.rm = TRUE)

# Print the counts and means
cat("Number of AI values: ", AI_count, "\n")
cat("Number of Human values: ", Human_count, "\n")
cat("Mean Quality for AI: ", AI_mean, "\n")
cat("Mean Quality for Human: ", Human_mean, "\n")

# Mann-Whitney U test (Wilcoxon rank-sum test) to compare Quality scores between AI and Human
test_result <- wilcox.test(AI_data$Quality, Human_data$Quality)

# Print the test result
print(test_result)

# Optional: Create a boxplot to visualize the difference in Quality between AI and Human
boxplot(Quality ~ Perception, data = data, main = "Quality by Perception", xlab = "Perception", ylab = "Quality")

# Load necessary libraries
library(readxl)   # For reading Excel files
library(dplyr)    # For data manipulation


# Subset the data for each Media Type with AI and Human Perception
AI_video <- data %>% filter(Perception == "AI" & `Media Type` == "Video")
Human_video <- data %>% filter(Perception == "Human" & `Media Type` == "Video")

AI_image <- data %>% filter(Perception == "AI" & `Media Type` == "Image")
Human_image <- data %>% filter(Perception == "Human" & `Media Type` == "Image")

AI_text <- data %>% filter(Perception == "AI" & `Media Type` == "Text")
Human_text <- data %>% filter(Perception == "Human" & `Media Type` == "Text")

# Mann-Whitney U test (Wilcoxon rank-sum test) for each comparison
test_AI_Human_video <- wilcox.test(AI_video$Quality, Human_video$Quality)
test_AI_Human_image <- wilcox.test(AI_image$Quality, Human_image$Quality)
test_AI_Human_text <- wilcox.test(AI_text$Quality, Human_text$Quality)

# Print the test results for each comparison
cat("Mann-Whitney U test for AI Video vs Human Video: \n")
print(test_AI_Human_video)

cat("\nMann-Whitney U test for AI Image vs Human Image: \n")
print(test_AI_Human_image)

cat("\nMann-Whitney U test for AI Text vs Human Text: \n")
print(test_AI_Human_text)

# Optional: Create a boxplot to visualize the difference in Quality for each comparison
boxplot(Quality ~ Perception * `Media Type`, data = data, main = "Quality by Perception and Media Type", xlab = "Media Type and Perception", ylab = "Quality")




#TRUSTWORTHINESS vs PERCEPTION

# Subset the data for AI and Human Perception
AI_data <- data %>% filter(Perception == "AI")
Human_data <- data %>% filter(Perception == "Human")

# Check the number of AI and Human values
AI_count <- nrow(AI_data)
Human_count <- nrow(Human_data)

# Calculate the means of Trustworthiness for AI and Human
AI_mean <- mean(AI_data$Trustworthiness, na.rm = TRUE)
Human_mean <- mean(Human_data$Trustworthiness, na.rm = TRUE)

# Print the counts and means
cat("Number of AI values: ", AI_count, "\n")
cat("Number of Human values: ", Human_count, "\n")
cat("Mean Trustworthiness for AI: ", AI_mean, "\n")
cat("Mean Trustworthiness for Human: ", Human_mean, "\n")

# Mann-Whitney U test (Wilcoxon rank-sum test) to compare Trustworthiness scores between AI and Human
test_result <- wilcox.test(AI_data$Trustworthiness, Human_data$Trustworthiness)

# Print the test result
print(test_result)

# Optional: Create a boxplot to visualize the difference in Trustworthiness between AI and Human
boxplot(Trustworthiness ~ Perception, data = data, main = "Trustworthiness by Perception", 
        xlab = "Perception", ylab = "Trustworthiness")

# Subset the data for each Media Type with AI and Human Perception
AI_video <- data %>% filter(Perception == "AI" & `Media Type` == "Video")
Human_video <- data %>% filter(Perception == "Human" & `Media Type` == "Video")

AI_image <- data %>% filter(Perception == "AI" & `Media Type` == "Image")
Human_image <- data %>% filter(Perception == "Human" & `Media Type` == "Image")

AI_text <- data %>% filter(Perception == "AI" & `Media Type` == "Text")
Human_text <- data %>% filter(Perception == "Human" & `Media Type` == "Text")

# Mann-Whitney U test (Wilcoxon rank-sum test) for each comparison
test_AI_Human_video <- wilcox.test(AI_video$Trustworthiness, Human_video$Trustworthiness)
test_AI_Human_image <- wilcox.test(AI_image$Trustworthiness, Human_image$Trustworthiness)
test_AI_Human_text <- wilcox.test(AI_text$Trustworthiness, Human_text$Trustworthiness)

# Print the test results for each comparison
cat("Mann-Whitney U test for AI Video vs Human Video: \n")
print(test_AI_Human_video)

cat("\nMann-Whitney U test for AI Image vs Human Image: \n")
print(test_AI_Human_image)

cat("\nMann-Whitney U test for AI Text vs Human Text: \n")
print(test_AI_Human_text)

# Optional: Create a boxplot to visualize the difference in Trustworthiness for each comparison
boxplot(Trustworthiness ~ Perception * `Media Type`, data = data, 
        main = "Trustworthiness by Perception and Media Type", 
        xlab = "Media Type and Perception", ylab = "Trustworthiness")





#ENGAGEMENT vs PERCEPTION

# Subset the data for AI and Human Perception
AI_data <- data %>% filter(Perception == "AI")
Human_data <- data %>% filter(Perception == "Human")

# Check the number of AI and Human values
AI_count <- nrow(AI_data)
Human_count <- nrow(Human_data)

# Calculate the means of Engagement for AI and Human
AI_mean <- mean(AI_data$Engagement, na.rm = TRUE)
Human_mean <- mean(Human_data$Engagement, na.rm = TRUE)

# Print the counts and means
cat("Number of AI values: ", AI_count, "\n")
cat("Number of Human values: ", Human_count, "\n")
cat("Mean Engagement for AI: ", AI_mean, "\n")
cat("Mean Engagement for Human: ", Human_mean, "\n")

# Mann-Whitney U test (Wilcoxon rank-sum test) to compare Engagement scores between AI and Human
test_result <- wilcox.test(AI_data$Engagement, Human_data$Engagement)

# Print the test result
print(test_result)

# Optional: Create a boxplot to visualize the difference in Engagement between AI and Human
boxplot(Engagement ~ Perception, data = data, main = "Engagement by Perception", 
        xlab = "Perception", ylab = "Engagement")

# Subset the data for each Media Type with AI and Human Perception
AI_video <- data %>% filter(Perception == "AI" & `Media Type` == "Video")
Human_video <- data %>% filter(Perception == "Human" & `Media Type` == "Video")

AI_image <- data %>% filter(Perception == "AI" & `Media Type` == "Image")
Human_image <- data %>% filter(Perception == "Human" & `Media Type` == "Image")

AI_text <- data %>% filter(Perception == "AI" & `Media Type` == "Text")
Human_text <- data %>% filter(Perception == "Human" & `Media Type` == "Text")

# Mann-Whitney U test (Wilcoxon rank-sum test) for each comparison
test_AI_Human_video <- wilcox.test(AI_video$Engagement, Human_video$Engagement)
test_AI_Human_image <- wilcox.test(AI_image$Engagement, Human_image$Engagement)
test_AI_Human_text <- wilcox.test(AI_text$Engagement, Human_text$Engagement)

# Print the test results for each comparison
cat("Mann-Whitney U test for AI Video vs Human Video: \n")
print(test_AI_Human_video)

cat("\nMann-Whitney U test for AI Image vs Human Image: \n")
print(test_AI_Human_image)

cat("\nMann-Whitney U test for AI Text vs Human Text: \n")
print(test_AI_Human_text)

# Optional: Create a boxplot to visualize the difference in Engagement for each comparison
boxplot(Engagement ~ Perception * `Media Type`, data = data, 
        main = "Engagement by Perception and Media Type", 
        xlab = "Media Type and Perception", ylab = "Engagement")



#Did they give lower scores when they were right about the content source was AI?

# Define the file path
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV_Test.xlsx"

# Load the data from the "Perception" sheet
data <- read_excel(file_path, sheet = "Perception")

# Check the first few rows of the data to understand its structure
head(data)

# Continue with the same dataset
# First, let's look at correct AI identification vs Quality scores

# Filter for cases where content source was AI and participant correctly identified it
correct_AI_identification <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 1)

# Filter for cases where content source was AI but participant incorrectly identified it
incorrect_AI_identification <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 0)

# Calculate means
correct_AI_mean <- mean(correct_AI_identification$Quality, na.rm = TRUE)
incorrect_AI_mean <- mean(incorrect_AI_identification$Quality, na.rm = TRUE)

# Print results
cat("Number of correct AI identifications: ", nrow(correct_AI_identification), "\n")
cat("Number of incorrect AI identifications: ", nrow(incorrect_AI_identification), "\n")
cat("Mean Quality for correct AI identifications: ", correct_AI_mean, "\n")
cat("Mean Quality for incorrect AI identifications: ", incorrect_AI_mean, "\n")

# Statistical test
test_result_AI_correctness <- wilcox.test(
  correct_AI_identification$Quality, 
  incorrect_AI_identification$Quality
)
print(test_result_AI_correctness)

# Visualize the results
boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "AI"),
  main = "Quality Scores for AI Content by Correctness of Identification",
  xlab = "Correctness (0 = Incorrect, 1 = Correct)",
  ylab = "Quality Score"
)

# Now let's break it down by media type
# For Video
correct_AI_video <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 1 & `Media Type` == "Video")
incorrect_AI_video <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 0 & `Media Type` == "Video")

# For Image
correct_AI_image <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 1 & `Media Type` == "Image")
incorrect_AI_image <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 0 & `Media Type` == "Image")

# For Text
correct_AI_text <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 1 & `Media Type` == "Text")
incorrect_AI_text <- data %>% 
  filter(`Content Source` == "AI" & Correctness == 0 & `Media Type` == "Text")

# Statistical tests for each media type
test_video <- wilcox.test(
  correct_AI_video$Quality, 
  incorrect_AI_video$Quality
)

test_image <- wilcox.test(
  correct_AI_image$Quality, 
  incorrect_AI_image$Quality
)

test_text <- wilcox.test(
  correct_AI_text$Quality, 
  incorrect_AI_text$Quality
)

# Print results for each media type
cat("\nMann-Whitney U test for correctly vs incorrectly identified AI Video: \n")
print(test_video)
cat("\nMean Quality for correctly identified AI Video: ", mean(correct_AI_video$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified AI Video: ", mean(incorrect_AI_video$Quality, na.rm = TRUE), "\n")

cat("\nMann-Whitney U test for correctly vs incorrectly identified AI Image: \n")
print(test_image)
cat("\nMean Quality for correctly identified AI Image: ", mean(correct_AI_image$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified AI Image: ", mean(incorrect_AI_image$Quality, na.rm = TRUE), "\n")

cat("\nMann-Whitney U test for correctly vs incorrectly identified AI Text: \n")
print(test_text)
cat("\nMean Quality for correctly identified AI Text: ", mean(correct_AI_text$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified AI Text: ", mean(incorrect_AI_text$Quality, na.rm = TRUE), "\n")

# Create a boxplot for each media type
par(mfrow = c(1, 3))  # Set up a 1x3 grid for plots

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "AI" & `Media Type` == "Video"),
  main = "Quality for AI Video by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "AI" & `Media Type` == "Image"),
  main = "Quality for AI Image by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "AI" & `Media Type` == "Text"),
  main = "Quality for AI Text by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)


#Did they give higher scores when they were right about the content source was Human?
# Analyze Quality scores for human-created content based on correct identification

# Filter for cases where content source was Human and participant correctly identified it
correct_Human_identification <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 1)

# Filter for cases where content source was Human but participant incorrectly identified it
incorrect_Human_identification <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 0)

# Calculate means
correct_Human_mean <- mean(correct_Human_identification$Quality, na.rm = TRUE)
incorrect_Human_mean <- mean(incorrect_Human_identification$Quality, na.rm = TRUE)

# Print results
cat("Number of correct Human identifications: ", nrow(correct_Human_identification), "\n")
cat("Number of incorrect Human identifications: ", nrow(incorrect_Human_identification), "\n")
cat("Mean Quality for correct Human identifications: ", correct_Human_mean, "\n")
cat("Mean Quality for incorrect Human identifications: ", incorrect_Human_mean, "\n")

# Statistical test
test_result_Human_correctness <- wilcox.test(
  correct_Human_identification$Quality, 
  incorrect_Human_identification$Quality
)
print(test_result_Human_correctness)

# Visualize the results
boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "Human"),
  main = "Quality Scores for Human Content by Correctness of Identification",
  xlab = "Correctness (0 = Incorrect, 1 = Correct)",
  ylab = "Quality Score"
)

# Now let's break it down by media type
# For Video
correct_Human_video <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 1 & `Media Type` == "Video")
incorrect_Human_video <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 0 & `Media Type` == "Video")

# For Image
correct_Human_image <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 1 & `Media Type` == "Image")
incorrect_Human_image <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 0 & `Media Type` == "Image")

# For Text
correct_Human_text <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 1 & `Media Type` == "Text")
incorrect_Human_text <- data %>% 
  filter(`Content Source` == "Human" & Correctness == 0 & `Media Type` == "Text")

# Statistical tests for each media type
test_Human_video <- wilcox.test(
  correct_Human_video$Quality, 
  incorrect_Human_video$Quality
)

test_Human_image <- wilcox.test(
  correct_Human_image$Quality, 
  incorrect_Human_image$Quality
)

test_Human_text <- wilcox.test(
  correct_Human_text$Quality, 
  incorrect_Human_text$Quality
)

# Print results for each media type
cat("\nMann-Whitney U test for correctly vs incorrectly identified Human Video: \n")
print(test_Human_video)
cat("\nMean Quality for correctly identified Human Video: ", mean(correct_Human_video$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified Human Video: ", mean(incorrect_Human_video$Quality, na.rm = TRUE), "\n")

cat("\nMann-Whitney U test for correctly vs incorrectly identified Human Image: \n")
print(test_Human_image)
cat("\nMean Quality for correctly identified Human Image: ", mean(correct_Human_image$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified Human Image: ", mean(incorrect_Human_image$Quality, na.rm = TRUE), "\n")

cat("\nMann-Whitney U test for correctly vs incorrectly identified Human Text: \n")
print(test_Human_text)
cat("\nMean Quality for correctly identified Human Text: ", mean(correct_Human_text$Quality, na.rm = TRUE), "\n")
cat("Mean Quality for incorrectly identified Human Text: ", mean(incorrect_Human_text$Quality, na.rm = TRUE), "\n")

# Create a boxplot for each media type
par(mfrow = c(1, 3))  # Set up a 1x3 grid for plots

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "Human" & `Media Type` == "Video"),
  main = "Quality for Human Video by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "Human" & `Media Type` == "Image"),
  main = "Quality for Human Image by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)

boxplot(
  Quality ~ Correctness, 
  data = data %>% filter(`Content Source` == "Human" & `Media Type` == "Text"),
  main = "Quality for Human Text by Correctness",
  xlab = "Correctness",
  ylab = "Quality"
)



#ROBUSTNESS CHECK WITH CONTENT SOURCE

# Load necessary libraries
library(readxl)   # For reading Excel files
library(dplyr)    # For data manipulation

# QUALITY, TRUSTWORTHINESS, and ENGAGEMENT vs CONTENT SOURCE

# Define the file path
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV.xlsx"

# Load the data from the "Perception" sheet
data <- read_excel(file_path, sheet = "Perception")

# Check column names to ensure proper referencing
colnames(data)

# Ensure that Content Source column exists and is properly formatted
if (!"Content Source" %in% colnames(data)) {
  stop("Error: 'Content Source' column not found in the dataset.")
}

# Function to analyze each variable
analyze_variable <- function(var_name) {
  # Ensure that the column exists in the dataset
  if (!var_name %in% colnames(data)) {
    stop(paste("Error: Column", var_name, "not found in dataset."))
  }
  
  cat("\n\n###############################\n")
  cat(" ANALYSIS FOR:", var_name, "\n")
  cat("###############################\n\n")
  
  # Subset the data for AI and Human Content Source
  AI_data <- data %>% filter(`Content Source` == "AI")
  Human_data <- data %>% filter(`Content Source` == "Human")
  
  # Check the number of AI and Human values
  AI_count <- nrow(AI_data)
  Human_count <- nrow(Human_data)
  
  # Calculate the means
  AI_mean <- mean(AI_data[[var_name]], na.rm = TRUE)
  Human_mean <- mean(Human_data[[var_name]], na.rm = TRUE)
  
  # Print the counts and means
  cat("Number of AI values: ", AI_count, "\n")
  cat("Number of Human values: ", Human_count, "\n")
  cat("Mean", var_name, "for AI: ", AI_mean, "\n")
  cat("Mean", var_name, "for Human: ", Human_mean, "\n")
  
  # Mann-Whitney U test (Wilcoxon rank-sum test)
  test_result <- tryCatch({
    wilcox.test(AI_data[[var_name]], Human_data[[var_name]])
  }, error = function(e) {
    cat("Error in Wilcoxon test for", var_name, ":", e$message, "\n")
    return(NULL)
  })
  
  # Print the test result if valid
  if (!is.null(test_result)) print(test_result)
  
  # Boxplot for the variable
  boxplot(data[[var_name]] ~ data$`Content Source`, 
          main = paste(var_name, "by Content Source"), 
          xlab = "Content Source", ylab = var_name)
}

# Now run the function for each variable
analyze_variable("Quality")
analyze_variable("Trustworthiness")
analyze_variable("Engagement")


















# Load necessary libraries
library(readxl)   # For reading Excel files
library(dplyr)    # For data manipulation

# Load the data
file_path <- "/Users/alika/Desktop/Courses/Master/Thesis/Experiment/AI_Perception_Data_LV.xlsx"
data <- read_excel(file_path, sheet = "Perception")

# Function to analyze each variable across media types while keeping Content Source comparison
analyze_variable_by_media <- function(var_name) {
  # Ensure that the column exists in the dataset
  if (!var_name %in% colnames(data)) {
    stop(paste("Error: Column", var_name, "not found in dataset."))
  }
  
  # List of media types
  media_types <- unique(data$`Media Type`)
  
  # Print overall analysis
  cat("\n\n#######################################\n")
  cat(" OVERALL ANALYSIS FOR:", var_name, "\n")
  cat("#######################################\n\n")
  
  # Subset the data for AI and Human Content Source
  AI_data <- data %>% filter(`Content Source` == "AI")
  Human_data <- data %>% filter(`Content Source` == "Human")
  
  # Compute means
  AI_mean <- mean(AI_data[[var_name]], na.rm = TRUE)
  Human_mean <- mean(Human_data[[var_name]], na.rm = TRUE)
  
  # Print results
  cat("Overall Mean", var_name, "for AI: ", AI_mean, "\n")
  cat("Overall Mean", var_name, "for Human: ", Human_mean, "\n")
  
  # Mann-Whitney U test (Wilcoxon rank-sum test)
  test_result <- tryCatch({
    wilcox.test(AI_data[[var_name]], Human_data[[var_name]])
  }, error = function(e) {
    cat("Error in Wilcoxon test for", var_name, ":", e$message, "\n")
    return(NULL)
  })
  
  # Print test result if valid
  if (!is.null(test_result)) print(test_result)
  
  # Create an empty results table
  results_table <- data.frame(
    Media_Type = c("Overall", media_types),
    AI_Mean = NA,
    Human_Mean = NA,
    W_Statistic = NA,
    P_Value = NA,
    Significance = NA
  )
  
  # Store overall results
  results_table[1, 2:3] <- c(AI_mean, Human_mean)
  results_table[1, 4:5] <- c(test_result$statistic, test_result$p.value)
  results_table[1, 6] <- ifelse(test_result$p.value < 0.05, "***", "n.s.")
  
  # Loop through each media type
  for (i in seq_along(media_types)) {
    media <- media_types[i]
    
    # Subset data by media type and Content Source
    AI_media <- data %>% filter(`Content Source` == "AI" & `Media Type` == media)
    Human_media <- data %>% filter(`Content Source` == "Human" & `Media Type` == media)
    
    # Compute means
    AI_mean_media <- mean(AI_media[[var_name]], na.rm = TRUE)
    Human_mean_media <- mean(Human_media[[var_name]], na.rm = TRUE)
    
    # Mann-Whitney U test
    test_result_media <- tryCatch({
      wilcox.test(AI_media[[var_name]], Human_media[[var_name]])
    }, error = function(e) {
      cat("Error in Wilcoxon test for", var_name, "in", media, ":", e$message, "\n")
      return(NULL)
    })
    
    # Store results in table
    results_table[i + 1, 2:3] <- c(AI_mean_media, Human_mean_media)
    if (!is.null(test_result_media)) {
      results_table[i + 1, 4:5] <- c(test_result_media$statistic, test_result_media$p.value)
      results_table[i + 1, 6] <- ifelse(test_result_media$p.value < 0.05, "***", "n.s.")
    }
  }
  
  # Print the results table
  print(results_table)
  
  # Boxplot for the variable by Media Type and Content Source
  boxplot(data[[var_name]] ~ data$`Content Source` * data$`Media Type`, 
          main = paste(var_name, "by Content Source and Media Type"), 
          xlab = "Media Type and Content Source", ylab = var_name)
}

# Run analysis for each variable
analyze_variable_by_media("Quality")
analyze_variable_by_media("Trustworthiness")
analyze_variable_by_media("Engagement")








#DIGITAL LITERACY vs ACCURACY

df$Digital_Literacy <- as.numeric(df$`1 Digital Literate, 0 Digital Illiterate`)

df %>%
  group_by(Digital_Literacy) %>%
  summarise(
    Mean_Overall_Accuracy = mean(Overall_Accuracy, na.rm = TRUE),
    SD_Overall_Accuracy = sd(Overall_Accuracy, na.rm = TRUE),
    n = n()
  )

wilcox.test(Overall_Accuracy ~ Digital_Literacy, data = df, exact = FALSE)

library(ggplot2)
ggplot(df, aes(x = as.factor(Digital_Literacy), y = Overall_Accuracy)) +
  geom_boxplot() +
  labs(x = "Digital Literacy (0 = Illiterate, 1 = Literate)", y = "Overall Accuracy") +
  theme_minimal()

df %>%
  group_by(Digital_Literacy) %>%
  summarise(
    Mean_Video_Accuracy = mean(Video_Accuracy, na.rm = TRUE),
    SD_Video_Accuracy = sd(Video_Accuracy, na.rm = TRUE),
    Mean_Image_Accuracy = mean(Image_Accuracy, na.rm = TRUE),
    SD_Image_Accuracy = sd(Image_Accuracy, na.rm = TRUE),
    Mean_Text_Accuracy = mean(Text_Accuracy, na.rm = TRUE),
    SD_Text_Accuracy = sd(Text_Accuracy, na.rm = TRUE),
    n = n()
  )
wilcox.test(Video_Accuracy ~ Digital_Literacy, data = df, exact = FALSE)
wilcox.test(Image_Accuracy ~ Digital_Literacy, data = df, exact = FALSE)
wilcox.test(Text_Accuracy ~ Digital_Literacy, data = df, exact = FALSE)

library(ggplot2)

# Video Accuracy
ggplot(df, aes(x = as.factor(Digital_Literacy), y = Video_Accuracy)) +
  geom_boxplot() +
  labs(x = "Digital Literacy (0 = Digital Illiterate, 1 = Digital Literate)", y = "Video Accuracy") +
  theme_minimal()

# Image Accuracy
ggplot(df, aes(x = as.factor(Digital_Literacy), y = Image_Accuracy)) +
  geom_boxplot() +
  labs(x = "Digital Literacy (0 = Digital Illiterate, 1 = Digital Literate)", y = "Image Accuracy") +
  theme_minimal()

# Text Accuracy
ggplot(df, aes(x = as.factor(Digital_Literacy), y = Text_Accuracy)) +
  geom_boxplot() +
  labs(x = "Digital Literacy (0 = Digital Illiterate, 1 = Digital Literate)", y = "Text Accuracy") +
  theme_minimal()


#AI LITERACY vs ACCURACY


df$AI_Literacy <- as.numeric(df$`1 AI Literate, 0 AI Illiterate`)

df %>%
  group_by(AI_Literacy) %>%
  summarise(
    Mean_Overall_Accuracy = mean(Overall_Accuracy, na.rm = TRUE),
    SD_Overall_Accuracy = sd(Overall_Accuracy, na.rm = TRUE),
    n = n()
  )


wilcox.test(Overall_Accuracy ~ AI_Literacy, data = df, exact = FALSE)

library(ggplot2)
ggplot(df, aes(x = as.factor(AI_Literacy), y = Overall_Accuracy)) +
  geom_boxplot() +
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", y = "Overall Accuracy") +
  theme_minimal()


df %>%
  group_by(AI_Literacy) %>%
  summarise(
    Mean_Video_Accuracy = mean(Video_Accuracy, na.rm = TRUE),
    SD_Video_Accuracy = sd(Video_Accuracy, na.rm = TRUE),
    Mean_Image_Accuracy = mean(Image_Accuracy, na.rm = TRUE),
    SD_Image_Accuracy = sd(Image_Accuracy, na.rm = TRUE),
    Mean_Text_Accuracy = mean(Text_Accuracy, na.rm = TRUE),
    SD_Text_Accuracy = sd(Text_Accuracy, na.rm = TRUE),
    n = n()
  )
wilcox.test(Video_Accuracy ~ AI_Literacy, data = df, exact = FALSE)
wilcox.test(Image_Accuracy ~ AI_Literacy, data = df, exact = FALSE)
wilcox.test(Text_Accuracy ~ AI_Literacy, data = df, exact = FALSE)

library(ggplot2)

# Video Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Video_Accuracy)) +
  geom_boxplot() +
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", y = "Video Accuracy") +
  theme_minimal()

# Image Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Image_Accuracy)) +
  geom_boxplot() +
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", y = "Image Accuracy") +
  theme_minimal()

# Text Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Text_Accuracy)) +
  geom_boxplot() +
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", y = "Text Accuracy") +
  theme_minimal()




# AI LITERACY vs ACCURACY (ADJUSTED which means if the participant was Digitally illeterate, AI literacy adjusted as illeterate as well)
df$AI_Literacy <- as.numeric(df$Adjusted)

df %>% 
  group_by(AI_Literacy) %>% 
  summarise(
    Mean_Overall_Accuracy = mean(Overall_Accuracy, na.rm = TRUE),
    SD_Overall_Accuracy = sd(Overall_Accuracy, na.rm = TRUE),
    n = n()
  )

wilcox.test(Overall_Accuracy ~ AI_Literacy, data = df, exact = FALSE)

library(ggplot2)
ggplot(df, aes(x = as.factor(AI_Literacy), y = Overall_Accuracy)) + 
  geom_boxplot() + 
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", 
       y = "Overall Accuracy") + 
  theme_minimal()

df %>% 
  group_by(AI_Literacy) %>% 
  summarise(
    Mean_Video_Accuracy = mean(Video_Accuracy, na.rm = TRUE),
    SD_Video_Accuracy = sd(Video_Accuracy, na.rm = TRUE),
    Mean_Image_Accuracy = mean(Image_Accuracy, na.rm = TRUE),
    SD_Image_Accuracy = sd(Image_Accuracy, na.rm = TRUE),
    Mean_Text_Accuracy = mean(Text_Accuracy, na.rm = TRUE),
    SD_Text_Accuracy = sd(Text_Accuracy, na.rm = TRUE),
    n = n()
  )

wilcox.test(Video_Accuracy ~ AI_Literacy, data = df, exact = FALSE)
wilcox.test(Image_Accuracy ~ AI_Literacy, data = df, exact = FALSE)
wilcox.test(Text_Accuracy ~ AI_Literacy, data = df, exact = FALSE)

library(ggplot2)
# Video Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Video_Accuracy)) + 
  geom_boxplot() + 
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", 
       y = "Video Accuracy") + 
  theme_minimal()

# Image Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Image_Accuracy)) + 
  geom_boxplot() + 
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", 
       y = "Image Accuracy") + 
  theme_minimal()

# Text Accuracy
ggplot(df, aes(x = as.factor(AI_Literacy), y = Text_Accuracy)) + 
  geom_boxplot() + 
  labs(x = "AI Literacy (0 = AI Illiterate, 1 = AI Literate)", 
       y = "Text Accuracy") + 
  theme_minimal()

