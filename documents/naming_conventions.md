# Data Engineering Standards and Naming Conventions

## 1. General Principles
To maintain consistency and readability across the data platform, all objects must adhere to the following:
* **Snake Case:** Use `snake_case` with lowercase letters and underscores to separate words.
* **Language:** Use English for all names.
* **Reserved Words:** Do not use SQL reserved words as object names.

---

## 2. Table Naming Conventions
Tables are named according to their role within the Medallion Architecture.

### Bronze & Silver Layers
All names must start with the source system name, and table names must match their original names without renaming.
* **Pattern:** `<sourcesystem>_<entity>`
* **Components:**
    * `<sourcesystem>`: Name of the source system (e.g., crm, erp).
    * `<entity>`: Exact table name from the source system.
* **Example:** `crm_customer_info`.

### Gold Layer
Tables must use meaningful, business-aligned names starting with a category prefix.
* **Pattern:** `<category>_<entity>`

| Pattern | Meaning | Example(s) |
| :--- | :--- | :--- |
| `dim_` | Dimension table | `dim_product, dim_customer` |
| `fact_` | Fact table | `fact_sales` |
| `agg_` | Aggregated table | `agg_customer, agg_sales_monthly` |

---

## 3. Column Naming Conventions

### Surrogate Keys
All primary keys in dimension tables must use the `_key` suffix.
* **Pattern:** `<table_name>_key.
* **Example:** `customer_key` (Surrogate key in the `dim_customers` table).

### Technical Columns
System-generated metadata must start with the `dwh_` prefix.
* **Pattern:** `dwh_<column_name>`.
* **Example:** `dwh_load_sales` (System-generated column used to store when the record was loaded).

---

## 4. Stored Procedures
All stored procedures used for loading data must follow the naming pattern: `load_<layer>`.
* **Examples:**
    * `load_bronze`: Stored procedure for loading data into the Bronze Layer.
    * `load_silver`: Stored procedure for loading data into the Silver Layer.

---

## 5. Business Rules
The following logic must be applied during data processing to maintain data quality:

### Sales Calculations
* **Sum Sales Formula:** $Sum\ Sales = Quantity \times Price$.
* **Validation:** Negatives, Zeros, and Nulls are not allowed in core metrics.

### Derivation Logic
| Scenario | Rule |
| :--- | :--- |
| Sales is negative, zero, or null | Derive it using $Quantity \times Price$. |
| Price is zero or null | Calculate it using $Sales \div Quantity$. |
| Price is negative | Convert it to a positive value. |
