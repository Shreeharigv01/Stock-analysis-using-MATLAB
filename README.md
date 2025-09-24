# 📈 Stock Analysis using MATLAB (ARIMA & LSTM)

This project applies **time series forecasting techniques (ARIMA and LSTM models)** to predict stock market prices using MATLAB.  
It demonstrates how classical statistical methods and modern deep learning approaches compare in financial prediction tasks.

---

## 🚀 Features
- **ARIMA Model**  
  - Captures linear trends & seasonality.  
  - Useful for short-term forecasting.  

- **LSTM Model**  
  - Recurrent neural network specialized for sequential data.  
  - Captures long-term dependencies in stock prices.  
  - Outperforms ARIMA for highly volatile data.  

- **Comparison of Results**  
  - Forecast accuracy measured using RMSE & MAPE.  
  - Graphical comparison of predicted vs. actual stock prices.  

---


---

## 🔧 Requirements
- MATLAB R2021a or later (older versions may work).  
- Toolboxes:  
  - Econometrics Toolbox  
  - Deep Learning Toolbox  

---

## 📊 Dataset
You can download historical stock price data from the **NASDAQ website**:  
👉 [NASDAQ Historical Data](https://www.nasdaq.com/market-activity/stocks)

Example:  
1. Search for a ticker symbol (e.g., **AAPL** for Apple, **TSLA** for Tesla).  
2. Go to the “Historical Data” tab.  
3. Select the time period (e.g., 5 years).  
4. Click **Download** (CSV file).  
5. Place the CSV file in the `data/` folder.  

---

## ▶️ How to Run
1. Clone or download this repository.  
2. Download your dataset from NASDAQ and save it in `/data`.  
3. Open `codefile.m` in MATLAB.  
4. Run the live script step by step to:  
   - Load dataset  
   - Train ARIMA & LSTM models  
   - Compare results  

---

## 📊 Sample Results
*Placeholder for graphs — upload your PNG plots here, e.g.:*

- ARIMA forecast vs. actual  
- LSTM forecast vs. actual  

---

## 🔮 Future Improvements
- Hybrid ARIMA-LSTM model.  
- Transformer-based time series forecasting.  
- Multi-stock portfolio forecasting.  

---

## ✨ Author
Project developed as part of a **MATLAB-based stock market analysis exploration**, focusing on **ARIMA vs. LSTM approaches**.
