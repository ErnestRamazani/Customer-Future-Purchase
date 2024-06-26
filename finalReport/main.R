#Ernest Ramazani
#CSCI 48100: Data Mining
#Term Project: Code source
#Date Modifeid: 5/5/2023


install.packages("readxl")
install.packages("dplyr")
install.packages("lubridate")
install.packages("factoextra")
install.packages("tidyverse")
install.packages("readxl")
install.packages("factoextra")
install.packages("arules")
install.packages("plotly")
install.packages("arulesViz")
install.packages("reshape2")



#Reading the pacakges

library(readxl)
library(dplyr)
library(lubridate)
library(factoextra)
library(readxl)
library(tidyverse)
library(factoextra)
library(arules)
library(plotly)
library(arulesViz)
library(reshape2)


#   1. Which products are the most popular?

# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Group the data by StockCode and Description, and sum the Quantity sold for each group
product_sales <- aggregate(data$Quantity, by=list(data$StockCode, data$Description), FUN=sum)

# Name the columns of the resulting data frame
colnames(product_sales) <- c("StockCode", "Description", "TotalQuantity")

# Sort the products by sales in descending order
top_products <- product_sales[order(-product_sales$TotalQuantity),]

# Print the top 10 products by sales, with both StockCode and Description
head(top_products[,c("StockCode", "Description", "TotalQuantity")], n=10)


#  2. What is the trend in sales over time?


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Convert the InvoiceDate column to a date format
data$InvoiceDate <- as.Date(data$InvoiceDate, format="%m/%d/%Y %H:%M")

# Group the data by date and sum the Quantity sold for each day
daily_sales <- aggregate(data$Quantity, by=list(data$InvoiceDate), FUN=sum)

# Name the columns of the resulting data frame
colnames(daily_sales) <- c("Date", "TotalQuantity")

# Plot the daily sales over time
plot(daily_sales$Date, daily_sales$TotalQuantity, type="l", xlab="Date", ylab="Total Quantity Sold")


#  3. Which customers generate the most revenue?


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Calculate the total revenue for each customer
customer_revenue <- aggregate(data$Quantity * data$UnitPrice, by=list(data$CustomerID), FUN=sum)

# Name the columns of the resulting data frame
colnames(customer_revenue) <- c("CustomerID", "TotalRevenue")

# Sort the customers by revenue in descending order
top_customers <- customer_revenue[order(-customer_revenue$TotalRevenue),]

# Print the top 10 customers by revenue
head(top_customers, n=10)


#  4. What is the average revenue per customer?


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Group the data by customer and calculate the total revenue per customer
customer_revenue <- aggregate(data$UnitPrice*data$Quantity, by=list(data$CustomerID), FUN=sum)

# Calculate the average revenue per customer
mean_revenue <- mean(customer_revenue$x)

# Print the average revenue per customer
cat("The average revenue per customer is", mean_revenue, "\n")



#  5. What is the average unit price and quantity per country?


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Group the data by country and calculate the average unit price and quantity per country
avg_unit_price <- aggregate(data$UnitPrice, by=list(data$Country), FUN=mean)
avg_quantity <- aggregate(data$Quantity, by=list(data$Country), FUN=mean)

# Merge the two data frames by country
avg_price_quantity <- merge(avg_unit_price, avg_quantity, by="Group.1")

# Rename the columns
colnames(avg_price_quantity) <- c("Country", "AvgUnitPrice", "AvgQuantity")

# Print the table
print(avg_price_quantity)



#  6. What is the correlation between the quantity of products sold and revenue generated? 


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Calculate the total revenue for each transaction
data$TotalRevenue <- data$Quantity * data$UnitPrice

# Calculate the correlation between Quantity and TotalRevenue
correlation <- cor(data$Quantity, data$TotalRevenue)

# Print the correlation coefficient
print(correlation)


#  7. Associations


# Load the data into a data frame
data <- read_excel("OnlineRetail.xlsx")

# Filter out cancelled transactions and transactions without CustomerID
data <- data[!is.na(data$CustomerID) & data$Quantity > 0,]

# Convert the data to transactions format
transactions <- split(data$StockCode, data$InvoiceNo)

# Perform association rule mining
rules <- apriori(transactions, parameter = list(support = 0.01, confidence = 0.5, minlen = 2))

# Print the rules
inspect(rules)


#  8. Classifications
# Load the data into a data frame
library(readxl)
data <- read_excel("OnlineRetail.xlsx")

# Convert InvoiceDate to a date format
data$InvoiceDate <- as.Date(data$InvoiceDate, format="%m/%d/%Y")

# Calculate the Recency, Frequency, and Monetary Value for each customer
library(dplyr)
rfm_data <- data %>%
  group_by(CustomerID) %>%
  summarise(
    Recency = as.numeric(max(InvoiceDate)) - as.numeric(min(InvoiceDate)),
    Frequency = n_distinct(InvoiceNo),
    MonetaryValue = sum(UnitPrice*Quantity)
  )

# Standardize the RFM variables
scaled_rfm_data <- data.frame(scale(rfm_data[,2:4]))

# Perform k-means clustering to segment customers
set.seed(123)
k <- 3
kmeans_model <- kmeans(scaled_rfm_data, centers = k)

# Add the cluster assignments to the original RFM data frame
rfm_data$Segment <- as.factor(kmeans_model$cluster)

# Analyze the results
library(ggplot2)
ggplot(rfm_data, aes(x=Frequency, y=MonetaryValue, color=Segment)) +
  geom_point() +
  ggtitle("Customer Segmentation based on RFM Analysis") +
  xlab("Frequency") +
  ylab("Monetary Value")







#  9. Clustering




# Load the dataset
data <- read_excel("OnlineRetail.xlsx")

# Remove rows with missing CustomerID
data <- data %>% drop_na(CustomerID)

# Convert InvoiceDate to a date object
data$InvoiceDate <- as.POSIXct(data$InvoiceDate)

# Calculate total price per row
data <- data %>% mutate(TotalPrice = Quantity * UnitPrice)



#Perform RFM Analysis


# Calculate the snapshot date as the maximum invoice date + 1 day
snapshot_date <- max(data$InvoiceDate) + days(1)

# Calculate Recency, Frequency, and Monetary value for each customer
rfm_data <- data %>%
  group_by(CustomerID) %>%
  summarise(Recency = as.numeric(snapshot_date - max(InvoiceDate)),
            Frequency = n(),
            Monetary = sum(TotalPrice)) %>%
  ungroup()


#Scale the RFM data 
# Scale the RFM data
rfm_scaled <- scale(rfm_data[, c("Recency", "Frequency", "Monetary")])

#Perform clustering using K-means:

# Determine the optimal number of clusters using the Elbow method
fviz_nbclust(rfm_scaled, kmeans, method = "wss") + theme_minimal()

# Perform K-means clustering with the optimal number of clusters (replace k with the optimal number)
k <- 3
kmeans_result <- kmeans(rfm_scaled, centers = k)

#Attach the cluster labels to the original RFM data:
rfm_data$Cluster <- kmeans_result$cluster

#plot the rfm_data$cluster

library(ggplot2)
#Create a scatter plot matrix:
rfm_data %>%
  mutate(Cluster = factor(Cluster)) %>%  # Convert Cluster to a factor for better visualization
  ggplot() +
  geom_point(aes(x = Recency, y = Frequency, color = Cluster), alpha = 0.5) +
  theme_minimal() +
  labs(title = "Clusters in RFM Data", x = "Recency", y = "Frequency", color = "Cluster")




#10 Satisfaction

rfm_scaled <- rfm_data %>%
  select(Recency, Frequency, Monetary) %>%
  mutate(across(everything(), scale))

# K-means clustering on the standardized RFM data
set.seed(42) # Set a random seed for reproducibility
number_of_clusters <- 4
kmeans_result <- kmeans(rfm_scaled, centers = number_of_clusters)

# Add the cluster column to the rfm_data data frame
rfm_data$Cluster <- kmeans_result$cluster

# Merge the rfm_data data frame with the feedback_data
merged_data <- rfm_data %>%
  inner_join(feedback_data, by = "CustomerID")

# Calculate the average satisfaction score for each cluster
cluster_satisfaction <- merged_data %>%
  group_by(Cluster) %>%
  summarize(average_satisfaction = mean(Satisfaction),
            total_satisfied = sum(Satisfaction),
            total_unsatisfied = length(Satisfaction) - sum(Satisfaction),
            total_reviews = length(Satisfaction))

# Print the average satisfaction score by cluster
print(cluster_satisfaction)

# Visualize the average satisfaction score by cluster
ggplot(cluster_satisfaction, aes(x = factor(Cluster), y = average_satisfaction, fill = factor(Cluster))) +
  geom_col() +
  theme_minimal() +
  labs(title = "Average Satisfaction Score by Cluster",
       x = "Cluster",
       y = "Average Satisfaction Score",
       fill = "Cluster")

# Visualize the distribution of satisfied and unsatisfied customers in each cluster
cluster_satisfaction_distribution <- merged_data %>%
  group_by(Cluster, Satisfaction) %>%
  summarize(count = n())

# Visualize the distribution
ggplot(cluster_satisfaction_distribution, aes(x = factor(Cluster), y = count, fill = factor(Satisfaction))) +
  geom_col(position = "dodge") +
  theme_minimal() +
  scale_fill_manual(values = c("0" = "red", "1" = "green"), labels = c("Unsatisfied", "Satisfied")) +
  labs(title = "Distribution of Satisfied and Unsatisfied Customers by Cluster",
       x = "Cluster",
       y = "Number of Customers",
       fill = "Satisfaction")

#11 Regression

# Fit the logistic regression model
logistic_model <- glm(Satisfaction ~ Quantity + UnitPrice, data = data, family = binomial)

# Display the summary of the model
summary(logistic_model)

# Create a grid of values for Quantity and UnitPrice
quantity_grid <- seq(min(data$Quantity), max(data$Quantity), length.out = 100)
unitprice_grid <- seq(min(data$UnitPrice), max(data$UnitPrice), length.out = 100)
grid <- expand.grid(Quantity = quantity_grid, UnitPrice = unitprice_grid)

# Calculate the predicted probabilities for the grid values
grid$PredictedProbability <- predict(logistic_model, newdata = grid, type = "response")

# Create a 3D plot
plot <- plot_ly(grid, x = ~Quantity, y = ~UnitPrice, z = ~PredictedProbability, type = "scatter3d", mode = "markers", marker = list(size = 3, opacity = 0.5))
plot


#12 Recommendation 

# Proceed with the rest of the code
user_item_data <- data %>%
  select(CustomerID, StockCode, Quantity)

# Remove rows containing NAs in CustomerID or StockCode
user_item_data <- user_item_data[!is.na(user_item_data$CustomerID) & !is.na(user_item_data$StockCode),]

# Convert CustomerID and StockCode to factors
user_item_data$CustomerID <- as.factor(user_item_data$CustomerID)
user_item_data$StockCode <- as.factor(user_item_data$StockCode)

# Create a binaryRatingMatrix object
user_item_matrix <- dcast(user_item_data, CustomerID ~ StockCode, value.var = "Quantity", fun.aggregate = length)
user_item_matrix <- as.matrix(user_item_matrix[, -1]) # Remove the CustomerID column
user_item_matrix[user_item_matrix > 1] <- 1 # Convert to binary
rownames(user_item_matrix) <- user_item_data$CustomerID[!duplicated(user_item_data$CustomerID)] # Assign row names correctly
user_item_matrix <- as(user_item_matrix, "binaryRatingMatrix")

# Create a user-based collaborative filtering recommendation model
recomm_model <- Recommender(user_item_matrix, method = "UBCF")

# Get recommendations for the users
user1_recommendations <- predict(recomm_model, user_item_matrix[1,], n = 10)
user5_recommendations <- predict(recomm_model, user_item_matrix[5,], n = 10)

# Function to convert item index to StockCode and Description
get_stockcode_description <- function(item_indices, data) {
  unique_items <- data %>%
    select(StockCode, Description) %>%
    distinct()
  return(unique_items[item_indices,])
}

# Get StockCode and Description for user1_recommendations
user1_stockcodes <- get_stockcode_description(as.integer(user1_recommendations@items[[1]]), data)
print(user1_stockcodes)

# Get StockCode and Description for user5_recommendations
user5_stockcodes <- get_stockcode_description(as.integer(user5_recommendations@items[[1]]), data)
print(user5_stockcodes)






############################
#other users recommendations
# Get recommendations for user 19
user19_recommendations <- predict(recomm_model, user_item_matrix[19,], n = 10)

# Get StockCode and Description for user19_recommendations
user19_stockcodes <- get_stockcode_description(as.integer(user19_recommendations@items[[1]]), data)

# Convert the user1_stockcodes to a data frame
user1_stockcodes_df <- as.data.frame(user1_stockcodes)

# Add a column for the index (to be used for ordering)
user1_stockcodes_df$Index <- 1:nrow(user1_stockcodes_df)

# Plot the recommendations for user1
ggplot(user1_stockcodes_df, aes(x = reorder(StockCode, Index), y = Index, fill = StockCode)) +
  geom_col() +
  coord_flip() +
  theme_minimal() +
  labs(title = "Top 10 Recommendations for User 1",
       x = "StockCode",
       y = "Recommended Rank",
       fill = "StockCode") +
  guides(fill = FALSE) +
  scale_y_continuous(breaks = 1:10)

