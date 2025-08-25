# Data-Driven-Forecasting-to-Reduce-Divvy-Stockouts
Proactive Divvy demand forecasting. We cleaned Jan–Jun 2024 rides, built daily counts, stabilized variance (Box-Cox λ≈0.7), removed weekly seasonality (lag 7), and selected SARIMA(1,0,1)(2,1,2)[7]. 14-day forecasts track actuals and inform bike rebalancing, staffing, and service planning. 
