-- =============================================================
-- Bank Customer Churn & Deposit Risk Analysis - SQL queries
-- Database: MySQL 8  |  Table: bank_customers (10,000 rows)
-- Author: Tushar Jain
-- =============================================================

-- Table structure (loaded from the cleaned customer file)
CREATE TABLE bank_customers (
    customer_id      INT PRIMARY KEY,
    surname          VARCHAR(50),
    credit_score     INT,
    geography        VARCHAR(20),
    gender           VARCHAR(10),
    age              INT,
    tenure           INT,
    balance          DECIMAL(12,2),
    num_products     INT,
    has_cr_card      TINYINT,
    is_active        TINYINT,
    est_salary       DECIMAL(12,2),
    exited           TINYINT          -- 1 = customer closed account
);


-- Q1. Overall KPIs: customers, churned, churn rate, deposits lost
SELECT
    COUNT(*)                                             AS total_customers,
    SUM(exited)                                          AS churned_customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct,
    ROUND(SUM(balance) / 1000000, 1)                     AS total_deposits_mn,
    ROUND(SUM(CASE WHEN exited = 1 THEN balance END) / 1000000, 1) AS deposits_lost_mn
FROM bank_customers;


-- Q2. Churn rate and deposits lost by country
SELECT
    geography,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct,
    ROUND(SUM(CASE WHEN exited = 1 THEN balance END) / 1000000, 1) AS deposits_lost_mn
FROM bank_customers
GROUP BY geography
ORDER BY churn_rate_pct DESC;


-- Q3. Churn by age band
SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END                                                  AS age_band,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct
FROM bank_customers
GROUP BY age_band
ORDER BY age_band;


-- Q4. Active vs inactive members
SELECT
    CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END AS member_status,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct
FROM bank_customers
GROUP BY member_status;


-- Q5. Number of products held vs churn (cross-sell view)
SELECT
    num_products,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct,
    ROUND(AVG(balance), 0)                               AS avg_balance
FROM bank_customers
GROUP BY num_products
ORDER BY num_products;


-- Q6. Credit score band vs churn
SELECT
    CASE
        WHEN credit_score < 580 THEN '1. Below 580'
        WHEN credit_score < 670 THEN '2. 580-669'
        WHEN credit_score < 740 THEN '3. 670-739'
        WHEN credit_score < 800 THEN '4. 740-799'
        ELSE '5. 800+'
    END                                                  AS credit_band,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct
FROM bank_customers
GROUP BY credit_band
ORDER BY credit_band;


-- Q7. High-value customers (balance 100k+): how many left and how much money went
SELECT
    COUNT(*)                                             AS high_value_customers,
    SUM(exited)                                          AS high_value_churned,
    ROUND(AVG(exited) * 100, 1)                          AS churn_rate_pct,
    ROUND(SUM(CASE WHEN exited = 1 THEN balance END) / 1000000, 1) AS deposits_lost_mn
FROM bank_customers
WHERE balance >= 100000;


-- Q8. Share of total deposits lost that came from high-value customers
WITH lost AS (
    SELECT
        SUM(CASE WHEN exited = 1 THEN balance ELSE 0 END)                       AS all_lost,
        SUM(CASE WHEN exited = 1 AND balance >= 100000 THEN balance ELSE 0 END) AS hv_lost
    FROM bank_customers
)
SELECT ROUND(hv_lost / all_lost * 100, 1) AS pct_of_lost_deposits_from_high_value
FROM lost;


-- Q9. Rule-based churn risk score and how well it separates churners
WITH scored AS (
    SELECT *,
        (CASE WHEN geography = 'Germany'        THEN 2 ELSE 0 END)
      + (CASE WHEN age BETWEEN 45 AND 64        THEN 2 ELSE 0 END)
      + (CASE WHEN is_active = 0                THEN 2 ELSE 0 END)
      + (CASE WHEN num_products = 1             THEN 1 ELSE 0 END)
      + (CASE WHEN num_products >= 3            THEN 3 ELSE 0 END)
      + (CASE WHEN gender = 'Female'            THEN 1 ELSE 0 END) AS risk_score
    FROM bank_customers
)
SELECT
    CASE
        WHEN risk_score <= 2 THEN '1. Low'
        WHEN risk_score <= 4 THEN '2. Medium'
        WHEN risk_score <= 6 THEN '3. High'
        ELSE '4. Very high'
    END                                                  AS risk_band,
    COUNT(*)                                             AS customers,
    ROUND(AVG(exited) * 100, 1)                          AS actual_churn_pct
FROM scored
GROUP BY risk_band
ORDER BY risk_band;


-- Q10. Retention call list: existing customers with high risk and high balance
WITH scored AS (
    SELECT *,
        (CASE WHEN geography = 'Germany'        THEN 2 ELSE 0 END)
      + (CASE WHEN age BETWEEN 45 AND 64        THEN 2 ELSE 0 END)
      + (CASE WHEN is_active = 0                THEN 2 ELSE 0 END)
      + (CASE WHEN num_products = 1             THEN 1 ELSE 0 END)
      + (CASE WHEN num_products >= 3            THEN 3 ELSE 0 END)
      + (CASE WHEN gender = 'Female'            THEN 1 ELSE 0 END) AS risk_score
    FROM bank_customers
)
SELECT
    customer_id, geography, gender, age, num_products, is_active, balance, risk_score,
    RANK() OVER (ORDER BY risk_score DESC, balance DESC) AS call_priority
FROM scored
WHERE exited = 0
  AND risk_score >= 5
  AND balance >= 100000
ORDER BY call_priority
LIMIT 50;
