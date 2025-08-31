# 🚖 Uber Trip Analysis with OLAP CUBE  

This project demonstrates how **Business Intelligence (BI) tools** can be used to analyze Uber (Taxi) trip data using the Microsoft BI Stack.  
We applied **ETL processes, OLAP cubes, and Power BI dashboards** to extract useful insights that can help improve taxi service operations.  

---

## 📌 Project Overview  
- **Objective:** Improve taxi service quality, profit margins, and competitiveness using BI.  
- **Tools Used:**  
  - SQL Server (Database Engine)  
  - SSIS (Integration Services – ETL)  
  - SSAS (Analysis Services – OLAP)  
  - Power BI (Dashboards & Visualizations)  

---

## 📂 Datasets  
We used different types of data for the analysis:  

### 🔹 Operational Data (Internal)  
- Trip records: pick-up & drop-off locations, time, fare, payment method.  
- Driver performance: ratings, completed vs. cancelled trips.  
- Customer behavior: booking frequency, cancellations.  
- Revenue, costs, and commissions.  

### 🔹 External Data  
- Weather conditions (rain, storms = higher demand).  
- Traffic data (rush hours, accidents, congestion).  
- Local events & holidays (concerts, festivals, airport trips).  
- Fuel prices (impacting driver profitability).  

### 🔹 Decision Support Data  
- KPIs: revenue per trip, driver utilization rate, average waiting time.  
- Peak demand hours & hot zones (heatmaps).  
- Cancellation and retention rates.  
- Profit margin analysis by city/region.  

---

## ⚙️ Process Workflow  

1. **Data Storage:** All raw trip data stored in SQL Server.  
2. **ETL with SSIS:** Extract, Transform, and Load data from multiple sources.  
3. **OLAP Cube with SSAS:** Build cubes to analyze trips by time, location, and driver performance.  
4. **Visualization with Power BI:** Create dashboards for KPIs, revenue, demand zones, and insights.  

---

## 📊 Dashboards & Insights  

- Peak demand hours are between **6 PM – 9 PM**.  
- Rainy weather increases trip requests by **~30%**.  
- High-rated drivers complete more trips and earn better commissions.  
- City centers show the highest demand compared to outer zones.  

---

## 🌍 Benefits in Industry  

- Handles large datasets efficiently.  
- Provides **real-time insights** for managers.  
- Scalable for local or global taxi services.  
- Helps improve customer satisfaction and profitability.  

---

## 🚀 Conclusion  

Business Intelligence transforms raw taxi trip data into **actionable insights**.  
With SQL Server, SSIS, SSAS, and Power BI, we built a framework that can help taxi companies improve operations, reduce costs, and increase profits.  

---

✍️ **Developed by:** [Your Group Members]  
📅 **Project:** Business Intelligence Mini Project
