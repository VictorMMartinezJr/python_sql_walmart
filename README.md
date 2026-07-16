# Walmart Data Analysis: SQL + Python

## Project Overview

<img width="1920" height="1080" alt="Image" src="https://github.com/user-attachments/assets/97e0dc26-5d99-4646-90c5-50bec190e53a" />


This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. Utilizing Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions.
---

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, SQL (PostgreSQL)
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas sqlalchemy psycopg2
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Price` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into PostgreSQL
   - **Set Up Connections**: Connect to PostgreSQL using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up tables in PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
   - **Documentation**: Keep clear notes of each query's objective, approach, and results.
     
---

## Requirements

- **Python 3.8+**
- **SQL Databases**: PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `psycopg2`
- **Kaggle API Key** (for data downloading)
<img width="640" height="306" alt="Image" src="https://github.com/user-attachments/assets/11ae73d8-5f38-4e6d-82d9-b540acf32a53" />

## Getting Started

1. Clone the repository:
2. Install Python libraries:
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.

---

## Project Structure

```plaintext
|-- data/                     # data csv file
|-- sql/                      # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
```
---
## Business Analysis
**1. Find different payment methods, # of transactions, and # of qty sold.**
```sql
SELECT 
	payment_method,
	COUNT(*) AS num_of_transactions,
	SUM(quantity) AS qty_sold
FROM walmart
GROUP BY payment_method;
```
---
**2. Identify the highest rated category in each branch. Display the branch, category, AVG rating.**
```sql
SELECT branch, category, avg_rating
FROM (
	SELECT
		branch,
		category,
		AVG(rating) AS avg_rating,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank 
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1;
```
---
**3. Identify the busiest day for each branch based on the # of transactions.**
```sql
SELECT *
FROM (
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_of_week,
		COUNT(*) AS num_of_transactions,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1;
```
---
**4. Determine the avg, min, and max rating of products for each city.**
```sql
SELECT 
	city, 
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city
ORDER BY city;
```
**5. Calculate the total profit for each category by considering total profit. Display the category and the total profit ordered from highest to lowest.**
```sql

SELECT 
	category,
	SUM(total_price) AS total_revenue,
	SUM(total_price * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
```
---
**6. Determine the most common payment method for each Branch.**
```sql
SELECT branch, payment_method AS most_common_payment_method
FROM (
	SELECT 
		branch,
		payment_method,
		COUNT(*) as total_transations,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY branch, 2
	)
WHERE rank = 1;
```
---
**7. Categorize sales into 3 groups (MORNING, AFTERNOON EVENING). Find # of invoices for each shift.**
```sql
SELECT branch, 
	CASE
		WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(*) as num_of_invoices
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;
```
---
**8. Identify the 5 branches with the highest descreasing ratio in revenue compared from 2022 to 2023**
```sql
WITH revenue_2022 
AS (
	SELECT 
		branch,
		SUM(total_price) as total_revenue_2022
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY branch	
	),
revenue_2023 
AS (
	SELECT 
		branch,
		SUM(total_price) as total_revenue_2023
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY branch	
)
SELECT
	cys.branch, 
	total_revenue_2022,
	total_revenue_2023,
	ROUND((total_revenue_2022 - total_revenue_2023)::numeric / total_revenue_2022::numeric * 100, 2) AS declining_ratio
FROM revenue_2022 lys
JOIN revenue_2023 cys ON cys.branch = lys.branch
ORDER BY declining_ratio DESC
LIMIT 5;
```
---
## Future Enhancements

Possible extensions to this project:
- Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
- Automation of the data pipeline for real time data ingestion and analysis.

---

## Acknowledgments

- **Data Source**: Kaggle’s Walmart Sales Dataset
- **Inspiration**: Walmart’s business case studies on sales and supply chain optimization.
