# Enterprise Data Warehouse Implementation: Medallion Architecture

This repository showcases a modern Data Engineering solution built on **SQL Server**, designed to transform raw transactional data into actionable business intelligence. By leveraging the **Medallion Architecture**, the project ensures high data quality and a structured flow from ingestion to final reporting. 

---

---
## 🚀 Project Overview
This project involves:
1. **Data Architecture:** Designing a Modern Data Warehouse using the Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines:** Extracting, Transforming, and Loading data from source systtems into the warehouse.
3. **Data Modeling:** Developing fact and dimension tables optimised for analytical queries.
4. **Analytics & Reporting:** Creating SQL-based reports and dashboards for actionable insights.

This repository is an excellent resource for professionals, students, or anyone looking  to showcase expertise in:
- Data Engineering
- Data Analytics
- ETL Pipeline Developer
- Data Architect
- SQL Development
- Data Modeling

---

## 🏗️ Data Architecture & Workflow 
The data architecture for the system follows the Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

<img width="1411" height="822" alt="data_architecture drawio" src="https://github.com/user-attachments/assets/eb96a959-8cc4-486a-86ee-c21bb2fb8db7" />


1. **Bronze Layer:** Stores raw data as it is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer:** This layer includes data cleansing, standardisation, and normalisation processes to prepare data for analysys.
3. **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics. 

---
## 🎯 Project Objectives
The objective is to develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making. 

### Data Engineering Specifications - Building the Data Warehouse
- **Data Sources:** Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the lastest dataset only; historisation of data is not required.
- **Documentation:** Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analytics)
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behaviour**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making. 

---
## 🛠️ Tools & Technologies

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-0078D4?logo=microsoft&logoColor=white)

- **Database Engine:** [SQL Server Express](https://www.microsoft.com/en-au/sql-server/sql-server-downloads)
- **Database Management:** [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
- **System Design & Architecture:** [Draw.io](https://www.drawio.com/)
- **Project Management & Documentation:** [Notion](https://www.notion.so/)

---
## 📂 Repository Structure
```text
modern-sql-warehouse/
│
├── datasets/
|   ├── source_crm/
|   |   ├── cust_info.csv
|   |   ├── prd_info.csv
|   |   └── sales_details.csv
|   └── source_erp/
|        ├── CUST_AZ12.csv
|        ├── LOC_A101.csv
|        └── PX_CAT_G1V2.csv
|
├── documents/
|   ├── data_architecture.png
|   ├── data_catalog.md
|   ├── data_flow.png
|   ├── data_integration.png
|   ├── data_model.png
|   └── naming_conventions.md
|
├── scripts/
|   ├── bronze/
|   |   ├── ddl_bronze.sql
|   |   └── usp_load_bronze.sql
|   ├── gold/
|   |   ├── ddl_gold.sql
|   ├── silver/
|   |   ├── ddl_silver.sql
|   |   └── usp_load_silver.sql
|   └── init_database.sql
|
├── tests/
|   ├── quality_checks_gold.sql
|   └── quality_checks_silver.sql
|
├── LICENSE
|
└── README.md
```
---
## ⚙️ Execution Flow
To build the warehouse from scratch, execute the scripts in the following order:
1. `init_database.sql` — Sets up the database and schemas.
2. `scripts/bronze/` — Loads raw CSV data into staging tables.
3. `scripts/silver/` — Cleans data and applies business logic.
4. `scripts/gold/` — Populates the final Star Schema for reporting.
5. `tests/` — Run quality checks to ensure data integrity.

---
## 👤 About Me

---

## 📜 License
Licensed under the [MIT License](LICENSE). Feel free to use and adapt this project into your own professional growth.



