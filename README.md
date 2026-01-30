# 📦 Olist E-commerce Analytics Project

This project aims to build an **end-to-end analytics platform** using the public **Olist Brazilian E-commerce dataset (Kaggle)**, simulating a real-world production database and delivering business insights through Power BI dashboards.

The main focus of this project is **data modeling, SQL-based transformations, and the creation of a reusable analytics layer** to support sales, customer, and logistics analysis.

---

## 🧠 Architecture Overview

1. Load raw data from Kaggle into a **PostgreSQL** database  
2. Create a **transformation schema** for data cleaning and processing  
3. Model the data using a **Star Schema**  
4. Create an **analytics schema** with materialized views  
5. Consume the analytics layer in **Power BI** for KPI visualization  

---

## 🗄️ Data Modeling

The data was modeled using a **Star Schema**, a dimensional modeling approach optimized for analytical workloads, enabling:
- High-performance queries
- Clear business logic
- Drill-down capabilities through joins with dimension tables

### 📐 Dimension Tables
- `dim_location`
- `dim_customer`
- `dim_seller`
- `dim_product`
- `dim_time`
- `dim_order_status`

### 📊 Fact Tables
- `fact_orders`
- `fact_order_item`

---

## 🔄 Transformation Layer (SQL)

A dedicated **transformation schema** was created where raw data was:
- Cleaned
- Standardized
- Enriched
- Loaded into dimension and fact tables

All business rules and KPI logic were implemented **in SQL**, ensuring the database acts as the **single source of truth**.

---

## 📈 Analytics Layer (`analytics` schema)

Within the `analytics` schema, multiple **materialized views** were created to support analytics and reporting.

### 🔹 Core Views (used by Power BI)
- `vw_sales`
- `vw_logistics`

### 🔹 Additional Analytical Views
- Revenue & Sales
- Time & Seasonality
- Customers & Satisfaction
- Logistics & SLA

These views allow advanced analysis while keeping Power BI focused solely on visualization.

---

## 📊 Power BI Dashboard

The Power BI dashboard connects directly to the **materialized views** in the `analytics` schema, focusing on **KPI visualization and business insights**.

### 🖼️ Dashboard Preview

#### Revenue & Sales
![Revenue & Sales](https://github.com/goncalosantos96/olist_e_commerce_project/blob/main/powerbi/revenue_sales.png)

#### Logistics & SLA
![Logistics & SLA](https://github.com/goncalosantos96/olist_e_commerce_project/blob/main/powerbi/logistics_sla.png)

#### Customer Satisfaction
![Customer Satisfaction](https://github.com/goncalosantos96/olist_e_commerce_project/blob/main/powerbi/customer_satisfaction.png)

> Note: Only screenshots are provided due to Power BI licensing limitations.

---

## ⚠️ Project Assumptions

The following assumptions were made during project development:

- Each city has **one and only one `zip_code_prefix`**
- Orders not delivered after **60 days** were considered **not delivered**
- Delivered orders without approval date used the **purchase date** for delivery time calculation
- Delivered orders without delivery date used the **estimated delivery date**
- Delivery lead time was calculated **starting from the order approval date**, when the order can proceed to the customer

These assumptions ensure analytical consistency given dataset limitations.

---

## 📌 Key Business Insights

Based on the analysis performed and the dashboards developed, the following key business insights were identified:

- **Revenue Growth**: Revenue shows a clear upward trend over time, indicating sustained business growth and strong overall business health.
- **Top Revenue-Generating Categories**: The top three product categories by revenue are **House & Construction**, **Electronics & Technology**, and **Cosmetics & Hygiene**.
- **Geographical Revenue Distribution**: **São Paulo (SP)** is the state responsible for the highest share of total revenue.
- **Delivery SLA Performance**: Approximately **94% of orders are delivered within the estimated delivery time**, reflecting solid logistics performance.
- **SLA Under High Demand**: Periods of sharp growth in order volume led to temporary declines and instability in delivery SLA. This issue was later mitigated and stabilized, indicating improved logistical readiness to handle higher demand.
- **Continuous Improvement in Deliveries**: Over the full historical period, there is a clear reduction in how late orders arrive beyond the estimated delivery date.
- **Order Volume vs Delays**: Increases in late deliveries coincide with spikes in order volume, reinforcing the initial logistics strain during growth phases, followed by operational improvements.
- **Customer Satisfaction Impact**: Customer satisfaction is strongly influenced by delivery timeliness. Late deliveries show a sharp drop in average review scores, highlighting the direct impact of SLA performance on customer experience.

---

## 🛠️ Technologies Used

- **Database**: PostgreSQL  
- **Data Transformation**: SQL  
- **Visualization & KPIs**: Power BI  
- **Dataset**: Olist Brazilian E-commerce Dataset (Kaggle)

---

## 🎯 Project Goals

- Simulate a real-world analytics environment
- Apply dimensional data modeling best practices
- Centralize business logic in SQL
- Build a reusable analytics layer
- Deliver clear and actionable dashboards

---

## 📌 Dataset Source

The dataset used in this project is publicly available on Kaggle:
> Olist Brazilian E-commerce Dataset

---

