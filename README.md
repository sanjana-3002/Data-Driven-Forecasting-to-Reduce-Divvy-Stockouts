# Riding Ahead of Demand — Forecasting Divvy Bike Shortages

Forecast daily **Divvy bike demand** to prevent stockouts and guide **rebalancing, staffing, and service planning**. This repo turns raw trip logs into reliable short-term forecasts using a clean time-series pipeline.

---

## 🚀 Overview

* **Goal:** Anticipate near-term demand so operations teams can **rebalance bikes before shortages happen**.
* **Scope:** City-level daily rides (Jan–Jun 2024), with guidance to extend to **station-level** and **weather-aware** models.
* **Method:** Box-Cox variance stabilization → weekly seasonality handling → **SARIMA** modeling → 14-day rolling forecasts.

---

## 🔢 Data

* **Source:** Divvy/Chicago open trip data (Jan–Jun 2024).
* **Unit:** Daily completed rides (aggregated from trips).
* **Notes:** Remove incomplete days/ingestion glitches; align to calendar; optional holiday/weekend flags.

---

## 🧪 Method & Model

1. **Aggregation:** trips → **daily ride counts**.
2. **Stabilize variance:** **Box-Cox** (λ ≈ 0.7 worked well).
3. **Seasonality:** detect **weekly cycle (s=7)** → seasonal differencing **D=1**.
4. **Selection:** compare candidates via AIC/BIC & residual checks; chosen model:

   * **SARIMA(1,0,1)(2,1,2)\[7]**
5. **Diagnostics:** residual ACF/PACF \~ white noise; Ljung–Box p-values non-significant across lags; no visible autocorrelated structure left.
6. **Forecasts:** 14-day horizon; compare to actuals on a rolling hold-out.

---

## 📈 Results

* Forecasts track day-of-week patterns and turning points with practical accuracy for **operational planning**.
* Useful for **pre-positioning** trucks, scheduling **shifts**, and **threshold alerts** on likely shortage days.

> For station-level forecasting, start with top-volume stations and pool with **SARIMAX + exogenous weather** (temperature, precipitation) to improve signal.

---

## ✅ Forecast Usage

* **Rebalancing:** If forecasted rides for a service area exceed bike supply by a threshold, create a **pre-move task**.
* **Staffing:** Align shifts with high-volume weekdays; maintain buffer on peak **weekends**.
* **Alerts:** Trigger warnings when predicted demand crosses **shortage thresholds**.

---

## ⚠️ Limitations

* City-level forecasts can **mask station imbalances**; use station-level models for routing.
* No weather/holiday regressors in the baseline; add **exogenous features** for longer horizons.
* Structural breaks (policy changes, events) require **model re-fit**.

---

## 🗺️ Roadmap

* [ ] Station-level SARIMAX with temperature/precipitation
* [ ] Automatic re-training & rolling backtests
* [ ] Streamlit **ops dashboard** (demand map + shortage alerts)
* [ ] Hierarchical forecasting (city → region → station)
