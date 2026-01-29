# Enterprise Data Warehouse Implementation: Medallion Architecture

This repository showcases a modern Data Engineering solution built on **SQL Server**, designed to transform raw transactional data into actionable business intelligence. By leveraging the **Medallion Architecture**, the project ensures high data quality and a structured flow from ingestion to final reporting. 

---
## 🚀 Project Overview
This project involves:
1. **Data Architecture:** Designing a Modern Data Warehouse using the Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines:** Extracting, Transforming, and Loading data from source systems into the warehouse.
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

## 🏗️ Project Architecture 
The project follows the Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

<img width="1411" height="822" alt="data_architecture drawio" src="https://github.com/user-attachments/assets/eb96a959-8cc4-486a-86ee-c21bb2fb8db7" />


1. **Bronze Layer:** Stores raw data as it is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer:** This layer includes data cleansing, standardisation, and normalisation processes to prepare data for analysis.
3. **Gold Layer:** Houses business-ready data modeled into a star schema required for reporting and analytics. 

---
## 🎯 Project Objectives
The objective is to develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making. 

### Data Engineering Specifications - Building the Data Warehouse
- **Data Sources:** Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality:** Cleanse and resolve data quality issues prior to analysis.
- **Integration:** Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope:** Focus on the latest dataset only; historisation of data is not required.
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

- **Database Engine:** [SQL Server Express](https://www.microsoft.com/en-au/sql-server/sql-server-downloads) — Served as the core RDBMS for data storage and processing through the Bronze, Silver, and Gold layers.
- **Development Enviroment:** [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) — The primary IDE used for authoring T-SQL scripts, managing database objects, and executing ETL procedures.
- **Data Modeling & Architecture:** [Draw.io](https://www.drawio.com/)  — Used to design the Medallion Architecture data flow and the Star Schema Entity Relationship Diagram (ERD).
- **Project Governance:** [Notion](https://www.notion.so/) — Used for end-to-end project management, documentation, and task tracking across all development stages.
- **Version Control:** [Git & GitHub](https://github.com/FroribertN/modern-sql-warehouse/commits/main) — Employed for codebase management, collaborative development, and maintaining a transparent version history of the ETL pipeline.
- **Detailed Roadmap:** You can access the full task breakdown and project implementation stages via my [Notion Project Procedure](https://www.notion.so/SQL-Data-Warehouse-Project-2eec6e1c547880bbbbcfd02f0ce2f766?source=copy_link).

---
## 📂 Repository Structure
```text
modern-sql-warehouse/
│
├── datasets/                           # RAW SOURCE DATA
|   ├── source_crm/                     # Customer Relationship Management extracts (Primary Sales and Customer source)
|   |   ├── cust_info.csv
|   |   ├── prd_info.csv
|   |   └── sales_details.csv
|   └── source_erp/                     # Enterprise Resource Planning extracts (Supplementary Location/Category source)
|        ├── CUST_AZ12.csv
|        ├── LOC_A101.csv
|        └── PX_CAT_G1V2.csv
|
├── documents/                          # PROJECT GOVERNANCE AND DESIGN 
|   ├── data_architecture.png           # Visual Overview of the Medallion Pipeline (Bronze → Silver → Gold)
|   ├── data_catalog.md                 # Metadata dictionary defining columns, types, and business descriptions 
|   ├── data_flow.png                   # Lineage diagram showing data movement from Source to Consumption
|   ├── data_integration.png            # Documentation/Diagram on how CRM and ERP keys were mapped/linked
|   ├── data_model.png                  # Entity Relationship Diagram (ERD) of the final Star Schema
|   └── naming_conventions.md           # Rules for SQL aliases, casing, and object naming (e.g., 'dim_', 'fact_')
|
├── scripts/                            # ETL LOGIC & PIPELINE STAGES
|   ├── bronze/                         # RAW LANDING: Ingests CSVs into SQL tables without changes
|   |   ├── ddl_bronze.sql              # Schema definitions for raw landing tables
|   |   └── usp_load_bronze.sql         # Stored Procedure for automated batch loading
|   ├── gold/                           # ANALYTICAL LAYER: Business-ready views and Star Schema modeling
|   |   ├── ddl_gold.sql                # Logic for creating Dim and Fact views with Surrogate Keys
|   ├── silver/                         # CLEANSED LAYER: Cleansing, deduplication, and standardisation logic
|   |   ├── ddl_silver.sql              # Schema definitions for cleaned tables
|   |   └── usp_load_silver.sql         # Stored Procedure: Logic for casting types, handling NULLs, and trimming strings
|   └── init_database.sql               # Environment setup script (creates database and schemas)
|
├── tests/                              # DATA QUALITY & INTEGRITY SUITE
|   ├── quality_checks_gold.sql         # Validates Star Schema (Unique Keys & Referential Integrity)
|   └── quality_checks_silver.sql       # Validates transformation logic (Data Profiling & Standardisation)
|
├── LICENSE                             # Open-source usage rights (MIT)
|
└── README.md                           # Primary project documentation and setup guide
```
---
## ⚙️ Execution Flow
To build the warehouse from scratch, execute the scripts in the following order:
1. [`init_database.sql`](https://github.com/FroribertN/modern-sql-warehouse/blob/main/scripts/init_database.sql) — Sets up the database and schemas.
2. [`scripts/bronze/`](https://github.com/FroribertN/modern-sql-warehouse/tree/main/scripts/bronze) — Loads raw CSV data into staging tables.
3. [`scripts/silver/`](https://github.com/FroribertN/modern-sql-warehouse/tree/main/scripts/silver) — Cleans data and applies business logic.
4. [`scripts/gold/`](https://github.com/FroribertN/modern-sql-warehouse/tree/main/scripts/gold) — Populates the final Star Schema for reporting.
5. [`tests/`](https://github.com/FroribertN/modern-sql-warehouse/tree/main/tests) — Run quality checks to ensure data integrity.

---
## 👤 About Me
Hi there, I'm Froribert Niyonkuru! I am a Data Engineering enthusiast focused on building scalable, high-performance data pipelines and warehouses. My passion lies in transforming "messy" raw data into clean, structured assets that drive business value.

Let's stay in touch! Feel free to connect with me on the following platforms:
<p align="left">
  <a href="https://github.com/FroribertN" target="_blank">
    <img src="https://img.shields.io/badge/GitHub-000000?style=for-the-badge&logo=github&logoColor=white"/>
  </a>
  <a href="https://linkedin.com/in/froribert-niyonkuru" target="_blank">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white"/>
  </a>
  <a href="https://www.facebook.com/froribert.niyonkuru" target="_blank">
    <img src="https://img.shields.io/badge/Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white"/>
  </a>
  <a href="mailto:forokaze11@gmail.com">
    <img src="https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white"/>
  </a>
  <a href="https://instagram.com/froribertniyonkuru" target="_blank">
    <img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white"/>
  </a>
  <a href="https://youtube.com/@froribertniyonkuru2317" target="_blank">
    <img src="https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white"/>
  </a>
</p>

---

## 📜 License
Licensed under the [MIT License](LICENSE). Feel free to use and adapt this project into your own professional growth.
