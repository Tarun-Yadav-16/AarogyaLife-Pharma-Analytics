# AarogyaLife-Pharma-Analytics

An end-to-end data analytics portfolio project that examines the commercial performance, payment collections, inventory availability and safety-reporting workload of a fictional pharmaceutical company.

The project uses Python (Pandas) for data cleaning and transformation, MySQL for business analysis and Power BI for data modelling, DAX calculations and interactive dashboards.

Important: This project uses a synthetic dataset created for learning and portfolio demonstration. It does not contain real patient information.

Business Problem

AarogyaLife Pharmaceuticals has sales, distributor, inventory, product, target and adverse-event data stored in separate tables. Management needs a single analytical view to answer the following questions:

Is the company growing profitably?

Which regions, therapy areas, products and channels generate the most revenue?

Which channels and distributors have collection delays?

Where are stock-outs, damaged units and below-reorder inventory creating operational risk?

What is the safety-reporting workload and where are reporting delays occurring?

The objective was to convert the disconnected data into reliable insights and a four-page management dashboard that supports commercial and operational decisions.

Project Workflow

Imported and inspected six CSV datasets.

Cleaned and transformed the data using beginner-friendly Pandas code.

Loaded the cleaned tables into MySQL.

Used joins, CTEs, aggregations and window functions to answer business questions.

Built a relational data model and DAX measures in Power BI.

Designed four dashboard pages for executives and operational teams.

Converted the findings into practical business recommendations.

Tools and Skills Used

Tool

How it was used

Python and Pandas

Data profiling, duplicate removal, missing-value handling, datatype conversion, text standardisation, feature creation and cleaned CSV export

MySQL 8+

Data validation, joins, CTEs, aggregations, ranking, LAG() analysis and business queries

Power BI

Data modelling, DAX measures, KPI cards, interactive charts and dashboard design

Power Query

Final data preparation and model checks inside Power BI

Dataset and Data Model

The analysis uses six related tables:

Table

Purpose

dim_product

Product, brand, generic name and therapy-area details

dim_distributor

Distributor, channel, region and credit-term details

fact_sales

Invoice-level sales, profit, returns and payment information

fact_inventory

Warehouse stock, reorder level, damage and stock-out information

fact_adverse_events

Safety-reporting volume, seriousness, status and reporting delay

targets

Annual sales targets by region

Dashboard Pages

1. Executive Overview

Tracks net sales, gross profit, units sold, return rate, payment performance, monthly sales, regional sales and target achievement.



2. Commercial Performance

Compares therapy areas, products, sales channels and payment performance to identify revenue leaders and collection risks.



3. Supply Chain and Inventory

Monitors stock-out days, inventory value, below-reorder records, damaged units, warehouse risk and products affected by stock-outs.



4. Safety Monitoring

Shows reporting volume, serious reports, cases under review, average reporting delay and reporting-delay distribution.



Key Findings

Total net sales reached approximately ₹23.40 crore, with ₹10.48 crore gross profit and a 44.77% gross margin.

Sales increased from ₹11.55 crore in 2024 to ₹11.85 crore in 2025, representing approximately 2.62% year-over-year growth.

South was the highest-sales region at approximately ₹6.27 crore, while Central had the lowest sales at approximately ₹2.01 crore.

Respiratory was the leading therapy area, generating approximately ₹8.86 crore in net sales.

VitalSalbu 12 was the highest-selling product, generating approximately ₹2.20 crore.

Retail Pharmacy was the largest channel at approximately ₹4.92 crore.

Overall on-time payment performance was 71.74%, below the 80% target.

Government Tender had the longest average collection period at 45.37 days.

Mumbai warehouse recorded the highest stock-out burden, with 683 stock-out days.

The data contained 420 adverse-event reports, including 43 serious reports, 96 cases under review and an average reporting delay of 18.9 days.

Business Recommendations

Create distributor and channel payment scorecards, with priority follow-up for overdue high-value Government Tender accounts.

Reallocate fast-moving respiratory products and review reorder points, beginning with the Mumbai warehouse.

Monitor products that combine high sales with high stock-out burden to reduce lost-sales risk.

Maintain a controlled review queue for serious and under-review safety reports and closely track reporting delays.

Use regional target-performance monitoring to protect strong markets and create improvement plans for underperforming regions.


How to Run the Project

1. Clean the data with Python

Install the required package:

pip install pandas

Place the six original CSV files in the folder expected by the Python script and run:

python python/AarogyaLife_Pharma_Data_Cleaning.py

2. Analyse the data in MySQL

Create a database named aarogyalife_pharma.

Import the six cleaned CSV files into their respective tables.

Open and execute sql/AarogyaLife_SQL_Queries.sql using MySQL 8 or later.

3. Explore the Power BI dashboard

Open powerbi/AarogyaLife_Pharma_Dashboard.pbix in Power BI Desktop and refresh the data-source settings if required.

Project Deliverables

Cleaned and transformed datasets

Reusable Python data-cleaning script

MySQL business-analysis queries

Four-page Power BI dashboard

Dashboard screenshots

Business-problem and deliverables document

Validated findings document

Business case presentation

Limitations

The dataset is synthetic and the results should not be treated as real company performance.

Safety-reporting volume represents operational workload only; it does not establish clinical incidence, product risk or medical causality.

Recommendations demonstrate an analytical decision-making approach and would require validation with real business stakeholders before implementation.

Author

Tarun Yadav
Aspiring Data Analyst | Python | SQL | Power BI

If you find this project useful, please consider giving the repository a star.
