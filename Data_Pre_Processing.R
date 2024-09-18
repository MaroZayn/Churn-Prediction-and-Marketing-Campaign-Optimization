# --- Library Imports ---
# Import necessary libraries
library(dplyr)
library(ggplot2)
library(ggplot2)
library(hrbrthemes) 
library(fastDummies)

# --- Data Loading ---
# Load data1 dataset
data1 <- read.csv("C:/Users/EMCCd/OneDrive/Documents/2024/M2 DS2E/Data/data1.csv")
str(data1)

# Load customerinfo dataset
customerinfo <- read.csv("C:/Users/EMCCd/OneDrive/Documents/2024/M2 DS2E/Data/an13.csv")
str(customerinfo)

# Load visits dataset
visits <- read.csv("C:/Users/EMCCd/OneDrive/Documents/2024/M2 DS2E/Data/in13.csv")
str(visits)

# --- Data Cleaning ---
# Remove the X column from all datasets
data1$X <- NULL
customerinfo$X <- NULL
visits$X <- NULL

# --- Data Processing and Merging ---
# Find the latest visit date for each customer
latest_visits <- visits %>%
  group_by(CodCliente) %>%
  summarize(latest_visit_date = max(datai, na.rm = TRUE))

# Rename column for merging
colnames(latest_visits)[1] <- "codcliente"

# Merge data1 with latest_visits
merged_data <- merge(data1, latest_visits, by = "codcliente", all.x = TRUE)


# For the "gender" column, replace missing values with random categories. 
# This approach is not very effective when missing data constitutes a high percentage of the dataset, but this is not the case for this column.
customerinfo$sesso[is.na(customerinfo$sesso)] <- "Unknown"


# Handle missing values in ultimo_ing.x
merged_data$ultimo_ing.x <- ifelse(is.na(merged_data$ultimo_ing.x) & !is.na(merged_data$latest_visit_date),
                                   merged_data$latest_visit_date,
                                   ifelse(is.na(merged_data$ultimo_ing.x),
                                          merged_data$abb13,
                                          merged_data$ultimo_ing.x))

# --- Data Type Conversion ---
# Convert date columns to Date type and factorize si2014
merged_data$ultimo_ing.x <- as.Date(merged_data$ultimo_ing.x, format = "%Y-%m-%d")
merged_data$abb13 <- as.Date(merged_data$abb13, format = "%Y-%m-%d")
merged_data$abb14 <- as.Date(merged_data$abb14, format = "%Y-%m-%d")
merged_data$si2014 <- as.factor(merged_data$si2014)

# Merge with customerinfo dataset
churn <- merged_data %>%
  left_join(customerinfo, by = "codcliente")

# --- Data Analysis and Visualization ---
# Handle outliers in data_nascita
str(churn$data_nascita)
churn$data_nascita <- as.numeric(churn$data_nascita)
z_scores <- scale(churn$data_nascita)
outliers <- abs(z_scores) > 3
outlier_values <- churn$data_nascita[outliers]

# Histogram of Birth Dates
hist(churn$data_nascita, main = "Histogram of Birth Dates", xlab = "Birth Date")

# Median calculation and outlier handling
valid_data_nascita <- churn$data_nascita[!churn$data_nascita %in% outlier_values]
median_value <- median(valid_data_nascita, na.rm = TRUE)
churn$data_nascita[churn$data_nascita %in% outlier_values] <- median_value

# Recalculate and replace new outliers
# ... [repeat the outlier handling steps as above]

# Histogram of Data Nascita (after outlier handling)
library(ggplot2)
library(hrbrthemes) # For nice themes

# Assuming 'churn$data_nascita' is a numeric vector of birth years
# First, ensure that the data is in numeric form
churn$data_nascita <- as.numeric(as.character(churn$data_nascita))

# Now create the histogram with ggplot2

churn$data_nascita <- as.numeric(as.character(churn$data_nascita))

# Now create the histogram with ggplot2
ggplot(churn, aes(x = data_nascita)) +
  geom_histogram(
    binwidth = 1, # Choose an appropriate binwidth for your data
    fill = "blue", 
    color = "black"
  ) +
  labs(
    title = "Histogram of Data di nascita Variable",
    x = "Data Nascita",
    y = "Frequency"
  ) +
  theme_ipsum() + # Using hrbrthemes for a nicer theme
  theme(
    plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12)
  ) # Adjust text sizes and align the title




# --- Feature Engineering ---
# Create age and tenure variables
# age: Convert the year of birth into age using 2014 as the reference year.
churn$age <- 2014 - churn$data_nascita

# Create a "tenure" variable that represents the difference between two columns; 
# a value of 0 indicates a client who is potentially at risk of churning (leaving). 
# This variable can also signify if the client has visited the museum at least once, where a small value suggests a recent visit.
churn$tenure <- as.numeric(churn$ultimo_ing.x - churn$abb13)

# Create dummy variables for categorical columns
churn <- dummy_cols(churn, select_columns = "agenzia_tipo", remove_selected_columns = TRUE)
churn <- dummy_cols(churn, select_columns = "tipo_pag", remove_first_dummy = FALSE, remove_selected_columns = TRUE)
churn <- dummy_cols(churn, select_columns = "sesso", remove_first_dummy = FALSE, remove_selected_columns = TRUE)
churn <- dummy_cols(churn, select_columns = "riduzione", remove_first_dummy = FALSE, remove_selected_columns = TRUE)

# New vs. Established Customers: 
# Create a binary variable from "Nuovo_abonn" to differentiate between new and established clients.
churn$Is_New_Customer <- ifelse(churn$nuovo_abb == "NUOVO ABBONATO", 1, 0)

# --- Data Cleanup ---
# Remove unwanted variables
churn$data_inizio <- NULL
churn$data_nascita <- NULL
churn$nuovo_abb <- NULL
churn$agenzia <- NULL
churn$cap <- NULL
churn$comune <- NULL
churn$sconto <- NULL
churn$ultimo_ing.x <- NULL
churn$abb13 <- NULL

# --- Final Adjustments and Export ---
# Correct dummy variable names
names(churn)[24:28] <- c("riduzione_OFFERTA CONVENZIONE", "riduzione_OFFERTA SU QUANTITATIVO", "riduzione_PASS 60 e VOUCHER OFFERTA")

# Export final churn dataset
write.csv(churn, file = "C:/Users/EMCCd/OneDrive/Documents/2024/churn.csv", row.names = FALSE)
