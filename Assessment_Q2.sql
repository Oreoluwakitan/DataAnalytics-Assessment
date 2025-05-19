SELECT
    /*create category for average customer transaction per month*/
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END 'frequency_category',
    customer_count,
    avg_transactions_per_month
FROM(
SELECT
    /*customer transaction count*/
    COUNT(b.id) customer_count,
    /*gets difference between first and last transaction. add 1 for when first and last transaction are the same*/
    ROUND(COUNT(b.id)/TIMESTAMPDIFF(MONTH , MIN(b.transaction_date), MAX(b.transaction_date)+1), 1) avg_transactions_per_month
/*creating relationship between customer and savings table tables*/
FROM users_customuser a
INNER JOIN savings_savingsaccount b
ON a.id = b.owner_id
GROUP BY a.id) t1
LIMIT 5;
