# DataAnalytics-Assessment


---

# 1. High-Value Customers with Multiple Products

---

## Per-Question Explanation

> **Scenario**: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
> 
> **Task**: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

### Approach

1. **Step 1: Use of Common Table Expression (CTE) – `plan_type`**

   * This CTE unifies data from savings and investment plans.
   * For each `owner_id`, it calculates:

     * The **count of transactions** (`COUNT(is_regular_savings)`)
     * The **sum of deposits** (`SUM(confirmed_amount)`)
     * A plan label (`'savings'` or `'investments'`)

2. **Step 2: Final Query**

   * Joins the `users_customuser` table to pull customer names.
   * Uses **correlated subqueries** to:

     * Fetch the transaction count per user for both savings and investment plans.
     * Compute the total deposits across both plan types.
   * Applies a `HAVING` clause to **filter customers** with:

     * At least **one savings plan**
     * At least **one investment plan**

3. **Step 3: Output**

   * Shows customer name, savings and investment counts, and total deposits.
   * Orders by the total deposit.
   * Limits output to **top 5 results**.

---

## Challenges & Solutions

### 1. **Combining Plan Types**

* **Challenge**: Transactions for savings and investments exist in the same `savings_savingsaccount` table, but are distinguished by flags (`is_regular_savings` and `is_a_fund`).
* **Solution**: Used a **UNION** inside a CTE to consolidate both plan types, simplifying the main query.

### 2. **Avoiding Duplicates & Maintaining Performance**

* **Challenge**: Joining and aggregating across large tables could lead to performance issues.
* **Solution**: CTE was introduced to **reduce redundancy** and **minimize repeated aggregations**. Also, using **correlated subqueries** ensured filtering was performed only where necessary.

### 3. **Ensuring Correct Filtering**

* **Challenge**: Filtering customers with both types of plans without incorrect joins.
* **Solution**: Used the `HAVING` clause after grouping by `owner ID` to enforce the rule that each customer must have both a savings and an investment plan.

---

## Notes

* **LIMIT 5** is applied for preview purposes; it can be removed or adjusted for full results.
* Future optimizations could involve **indexing `plan_id`, `owner_id`, and `transaction_date`** for better performance on large datasets.



# 2. Transaction Frequency Analysis

---

## Per-Question Explanation

> **Scenario**:  The finance team wants to analyze how often customers transact to segment
them (e.g., frequent vs. occasional users).
> 
> **Task**:  Calculate the average number of transactions per customer per month and categorize them:
> * "High Frequency" (≥10 transactions/month)
> * "Medium Frequency" (3-9 transactions/month)
> * "Low Frequency" (≤2 transactions/month)`


### Approach

1. **Join Users and Transactions**

   * The query performs an inner join between `users_customuser` and `savings_savingsaccount` on the `owner_id` to connect each customer with their transaction records.

2. **Calculate Monthly Transaction Average**

   * For each customer:

     * Total transactions are counted.
     * The number of months between the first and last transaction is calculated using `TIMESTAMPDIFF(MONTH, MIN(b.transaction_date), MAX(b.transaction_date) + 1)`.
     * The average number of transactions per month is then calculated as `COUNT(b.id) / TIMESTAMPDIFF(MONTH, MIN(b.transaction_date), MAX(b.transaction_date) + 1)`.

3. **Categorize Customers**

   * Based on the computed average monthly transaction count:

     * **High Frequency**: ≥ 10 transactions/month
     * **Medium Frequency**: Between 3 and 9 transactions/month
     * **Low Frequency**: < 3 transactions/month

4. **Limit Results**

   * The outer query limits the result to 5 customers for preview purposes using `LIMIT 5`.

---

## Challenges & Solutions

### 1. **Division by Zero Risk**

* **Challenge**: If a customer had only one transaction or all transactions happened within the same month, the `TIMESTAMPDIFF` could result in zero months, causing a division error.
* **Solution**: Added `+1` inside `MAX(transaction_date) + 1` to ensure the difference is at least one month and avoid division by zero.

### 2. **Accurate Classification**

* **Challenge**: Properly defining frequency thresholds for business interpretation.
* **Solution**: Business rules were simplified into three tiers (High/Medium/Low) based on monthly averages to support clear customer segmentation.

### 3. **Performance Consideration**

* **Challenge**: Aggregating transaction data per user could be expensive with large datasets.
* **Solution**: Limited output with `LIMIT 5` for faster preview. For full-scale execution, consider indexing `owner_id` and `transaction_date` for faster aggregation.


# 3. Account Inactivity Alert

---

## Per-Question Explanation

> **Scenario**:  The ops team wants to flag accounts with no inflow transactions for over one
year.
> 
> **Task**: Find all active accounts (savings or investments) with no transactions in the last 1
year (365 days) .


### Approach

1. **Separate Logic by Plan Type**

   * The query is structured using a **UNION ALL** of two subqueries:
     * One for **regular savings** plans (`is_regular_savings = 1`)
     * Another for **investment** plans (`is_a_fund = 1`)
   * This design simplifies plan-specific logic and ensures clear labeling of the plan type in the output.

2. **Join `plans_plan` and `savings_savingsaccount` Tables**

   * Both subqueries join the `plans_plan` and `savings_savingsaccount` tables using `plan_id` to relate each plan to its transactions.

3. **Filter by Transaction Date**

   * Each subquery filters for transactions that occurred **more than 365 days ago** using:
     `transaction_date < CURDATE() - INTERVAL 365 DAY`

4. **Calculate Inactivity**

   * For each unique `owner_id` and `plan_id`, the query:

     * Retrieves the **most recent transaction date** using `MAX(transaction_date)`
     * Calculates **days of inactivity** as the difference between that date and the current date:
       `
       TIMESTAMPDIFF(DAY, MAX(transaction_date), CURDATE())
       `

5. **Label Plan Type**

   * A constant string ('Savings' or 'Investments') is added as `type` to distinguish between the two plan categories.

6. **Limit Results**

   * The final result set is limited to **5 rows** using `LIMIT 5` for sampling or preview.

---

## Challenges & Solutions

### 1. **Avoiding Inaccurate Inactivity Calculations**

* **Challenge**: Ensuring the calculation of inactivity is based on the latest transaction.
* **Solution**: Used `MAX(transaction_date)` inside both the SELECT clause and the `TIMESTAMPDIFF` to guarantee the calculation uses the most recent transaction.

### 2. **Plan Type Differentiation**

* **Challenge**: Accurately segmenting records by plan type (savings vs investment).
* **Solution**: Used separate subqueries with strict filtering (`is_regular_savings=1` vs `is_a_fund=1`) and labeled results explicitly with a constant `type` column.

### 3. **Readability and Scalability**

* **Challenge**: Combining logic for different plans without making the query too complex.
* **Solution**: Applied `UNION ALL` with clear grouping logic and plan-specific filtering to keep each block modular and easier to debug or extend.


# 4. Customer Lifetime Value (CLV) Estimation

---

## Per-Question Explanation

> **Scenario**:  Marketing wants to estimate CLV based on account tenure and transaction
volume (simplified model).
> 
> **Task**:  For each customer, assuming the profit_per_transaction is 0.1% of the transaction
value, calculate:
> * Account tenure (months since signup)
> * Total transactions
>* Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 *
avg_profit_per_transaction)
>* Order by estimated CLV from highest to lowest

---

### Approach

1. **Customer Information (`cust_info` CTE)**

   * Retrieves basic user data from the `users_customuser` table.
   * Calculates how long each customer has been with the business using:
     `
     TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) AS tenure_months
     `
   * Combines first and last names to create a readable name format.

2. **Transaction Metrics (`trans_fetch` CTE)**

   * Extracts total number of transactions per customer from `savings_savingsaccount`.
   * Calculates average profit per transaction using a simplified multiplier:
     `
     AVG(confirmed_amount * 0.001) AS avg_profit_per_transaction
     `

3. **Final CLV Calculation**

   * Combines both CTEs using an `INNER JOIN` on the customer ID.
   * Computes **Estimated CLV** using the formula:
     `
     ((total_transactions / tenure_months) * 12) * avg_profit_per_transaction
     `
   
4. **LIMIT Clause**

    * Limits output to the first 5 results for sampling or performance during testing.

---

## Challenges & Solutions

1. **Handling Customers with Short Tenure**

   * **Challenge**: Dividing by `tenure_months` could lead to errors or inflated values for new users (e.g., tenure = 0 or 1).
   * **Solution**:  Filtered out customers with `tenure_months < 1`.

2. **Profit Assumption**

   * **Challenge**: Estimating profit realistically from transaction data.
   * **Solution**: Used a proxy `0.1%` multiplier (`* 0.001`) to simulate profit margin per transaction. This can be updated later based on real financial data.

3. **Missing Users Without Transactions**

   * **Challenge**: Customers with no transactions are excluded due to the `INNER JOIN`.
   * **Solution**: This was intentional for performance and clarity. To include all users.

---

## Future Improvements on Question 2

* Add filtering by date ranges (e.g., only transactions from the last year).
* Include additional metadata (e.g., customer name or account type).
* Visualize the distribution of categories for reporting purposes.

## Future Enhancements on Question 3

* Include customer names for easier business review.
* Include a severity score or priority tag based on inactivity duration (e.g., over 2 years = Critical).