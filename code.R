library(forecast)
library(tseries)

# Step 1: Filter for Jan–June 2024
ts_data1 <- read.csv("/Users/sanjanawaghray/Documents/Illinois_Tech/2nd_Sem/Time Series/Project/ts_data.csv")
ts_data2 <- ts_data1[ts_data1$date >= as.Date("2024-01-01") & ts_data1$date <= as.Date("2024-06-30"), ]
ts_data <- ts(ts_data2$ride_count, frequency = 7)
View(ts_data)
ts_data$date <- as.Date(ts_data$date)

#Plotting the raw dataset
plot(ts_data, type = "l", col = "blue",
     main = "Ride Count Per Day 2024-2025",
     xlab = "Date", ylab = "Ride Count")

# Ensure ride_count has only positive values (Box-Cox doesn't allow zeros or negatives)
boxcox_result <- BoxCox.lambda(ts_data)
print(paste("Optimal lambda:", boxcox_result))

lambda <- BoxCox.lambda(ts_data)
ts_data$transformed <- BoxCox(ts_data, lambda)

seasonal_diff <- diff(ts_data$transformed, lag = 7)
plot.ts(seasonal_diff, main = "Seasonal Differenced (Lag 7) Box-Cox Transformed Series")

# ACF & PACF of raw ride count
acf(ts_data, main = "ACF of Raw Ride Count")
pacf(ts_data, main = "PACF of Raw Ride Count")

# ACF & PACF after Box-Cox + seasonal diff
acf(seasonal_diff, main = "ACF of Box-Cox + Lag-7 Differenced Series")
pacf(seasonal_diff, main = "PACF of Box-Cox + Lag-7 Differenced Series")


# Fit model using Box-Cox lambda and seasonal differencing internally
library(forecast)
model <- auto.arima(seasonal_diff, 
                    lambda = 0.7, 
                    seasonal = TRUE, 
                    stepwise = FALSE, 
                    approximation = FALSE)

model <- Arima(ts_data, order = c(1, 0, 1), seasonal = list(order = c(0, 1, 1), period = 7))

# Check summary and residuals
summary(model)
checkresiduals(model)

library(astsa)
sarima(seasonal_diff,
       p = 1, d = 0, q = 1, P=0,D=0,Q=1,S=7)
sarima(ts_data, p = 1, d = 0, q = 1, P=0,D=1,Q=1,S=7)

# Step 6: Forecast next 14 days
library("ggplot2")
forecast_result <- forecast(model, h = 14)
autoplot(forecast_result) + ggtitle("Forecasted Daily Ride Counts (with Seasonal Differencing)")

autoplot(forecast_result) +
  autolayer(ts_data$ride_count, series = "Actual", linetype = "dashed") +
  ggtitle("Actual vs Forecasted Ride Counts") +
  xlab("Date") + ylab("Ride Count")

summary(forecast_result)

###Actual vs forecasted
# Ensure date format
ts_data1$date <- as.Date(ts_data1$date)

# Extract actual values for 1–14 July 2024
actual_july <- ts_data1[ts_data1$date >= as.Date("2024-07-01") & ts_data1$date <= as.Date("2024-07-14"), ]

# Create forecast dataframe
forecast_df <- data.frame(
  date = seq(as.Date("2024-07-01"), by = "day", length.out = 14),
  forecast = as.numeric(forecast_result$mean)
)

# Merge actual and forecast
comparison <- merge(actual_july[, c("date", "ride_count")], forecast_df, by = "date", all = TRUE)

# Plot
library(ggplot2)
ggplot(comparison, aes(x = date)) +
  geom_line(aes(y = ride_count, color = "Actual")) +
  geom_line(aes(y = forecast, color = "Forecast")) +
  labs(title = "Actual vs Forecasted Ride Counts (1–14 July 2024)",
       x = "Date", y = "Ride Count") +
  scale_color_manual(values = c("Actual" = "blue", "Forecast" = "red")) +
  theme_minimal()
