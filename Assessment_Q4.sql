WITH cust_info AS (
    /*gets the customer info including tenure*/
    SELECT
        id customer_id,
        CONCAT(first_name,' ',last_name) AS name,
        TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE) tenure_months
    FROM users_customuser
),
    trans_fetch AS (
        /*gets the transaction count, and calculates the average per profit cost*/
        SELECT
            owner_id,
            COUNT(*) total_transactions,
            AVG(confirmed_amount * 0.001) avg_profit_per_transaction
        FROM savings_savingsaccount
        GROUP BY owner_id
    )

SELECT
    customer_id,
    name,
    tenure_months,
    total_transactions,
    /*calculates the Estimated customer lifetime value*/
    ROUND(((total_transactions/tenure_months)*12)
        * avg_profit_per_transaction, 2) AS estimated_clv
FROM cust_info a
INNER JOIN trans_fetch b
ON a.customer_id = b.owner_id
LIMIT 5;