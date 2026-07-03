# Bank Customer Churn Analysis

A Power BI dashboard analyzing customer churn for a European bank with 10,000 customers across France, Germany, and Spain.

## Overview

This project analyzes account data for 10,000 customers to identify who is most likely to churn and what drives that behavior, so the bank can target retention efforts effectively. The overall churn rate is **20%**.

## Key Findings

### 1. Germany has by far the highest churn
German customers churn at **32%**, compared to **16%** in France and **17%** in Spain — roughly double the rate of the other two countries, despite Germany having fewer total customers. This is the clearest risk signal in the data.

### 2. Churn rises sharply with age
Customers aged 50 and above churn at much higher rates than younger customers, with the **60+ group churning most**. Customers under 40 are the most stable.

### 3. Inactive members are more likely to leave
Customers flagged as inactive churn noticeably more than active members, making account engagement a strong predictor of retention.

### 4. Multiple products correlate with higher churn
Customers holding **3–4 products** churn at very high rates, while those with 1–2 products are far more stable — suggesting possible dissatisfaction or over-selling among heavy-product customers.

## Recommendation

The bank should prioritize retention efforts on its highest-risk segment: **older, inactive customers in Germany**. Targeted engagement campaigns, proactive outreach to inactive accounts, and a review of the product experience for multi-product holders would likely have the greatest impact on reducing churn.

## Tools & Process

Built in **Power BI**. The raw data arrived across two messy Excel sheets and was cleaned in **Power Query**:

- Standardized inconsistent country labels (e.g. FRA / France / French → France)
- Converted currency-formatted text (€) to numeric values
- Removed duplicate records
- Merged customer demographics with account information into a single model

Measures (churn rate, averages) and segment columns (age bands, activity status) were created in **DAX**.

## Dashboard Features

- KPI cards: total customers, churn rate, average age
- Churn analysis by geography, age band, number of products, and activity status
- Geographic map of customer distribution
- Interactive slicers for Geography and Gender

## Dataset

10,000 customer records including credit score, geography, gender, age, tenure, balance, number of products, card status, activity status, and churn flag.
