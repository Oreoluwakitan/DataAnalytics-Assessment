SELECT *
FROM
(SELECT
    b.plan_id,
    a.owner_id,
    'Savings' type,
    /*gets the last transaction date of a customer*/
    MAX(transaction_date) last_transaction_date,
    /*calculates the number of inactive days relative to the current date*/
    TIMESTAMPDIFF(DAY, MAX(transaction_date), CURDATE()) inactivity_days
FROM plans_plan a
JOIN savings_savingsaccount b
ON a.id = b.plan_id
/*fetches only transactions that are of type 'savings'*/
WHERE is_regular_savings= 1
  /*filters for dates less than the differance between the current date and 365 days*/
  AND transaction_date < CURDATE() - INTERVAL 365 DAY
GROUP BY a.owner_id, b.plan_id

UNION ALL

SELECT
    b.plan_id,
    a.owner_id,
    'Investments' type,
    /*gets the last transaction date of a customer*/
    MAX(transaction_date) last_transaction_date,
    /*calculates the number of inactive days relative to the current date*/
    TIMESTAMPDIFF(DAY, MAX(transaction_date), CURDATE()) inactivity_days
FROM plans_plan a
JOIN savings_savingsaccount b
ON a.id = b.plan_id
/*fetches only transactions that are of type 'investment'*/
WHERE is_a_fund= 1
    /*filters for dates less than the differance between the current date and 365 days*/
  AND transaction_date < CURDATE() - INTERVAL 365 DAY
GROUP BY a.owner_id, plan_id)t1
LIMIT 5;
