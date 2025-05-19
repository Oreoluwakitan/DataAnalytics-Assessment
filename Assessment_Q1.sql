#common table expression to hold the union of both plan types for easy access
WITH plan_type AS (
    /*gets the customer counts and sum of deposit of clients with savings plan*/
    SELECT
        a.owner_id,
        COUNT(is_regular_savings) count,
        SUM(confirmed_amount) deposit,
        'savings' plan
    FROM plans_plan a
    JOIN savings_savingsaccount b
    ON a.id = b.plan_id
    WHERE is_regular_savings= 1
    GROUP BY a.owner_id
    UNION
    /*gets the customer counts and sum of deposit of clients with investment plan*/
    SELECT
        a.owner_id,
        COUNT(is_regular_savings) count,
        SUM(confirmed_amount) deposit,
        'investments' plan
    FROM plans_plan a
    JOIN savings_savingsaccount b
    ON a.id = b.plan_id
    WHERE is_a_fund= 1
    GROUP BY a.owner_id
)

SELECT
    t1.id owner_id,
    CONCAT(first_name,' ',last_name) as name,
    /*gets the count of transactions for customers who have savings plans from plan_type*/
    (SELECT
         count
     FROM plan_type t2
     WHERE t2.owner_id = t1.id
       AND t2.plan = 'savings') savings_count,
    /*gets the count of transactions for customers who have investments plans from plan_type*/
    (SELECT
         count
     FROM plan_type t2
     WHERE t2.owner_id = t1.id
       AND t2.plan = 'investments') investment_count,
    /*gets the amount for all confirmed_amounts transacted savings + investment*/
    (SELECT
         SUM(deposit)
     FROM plan_type t2
     WHERE t2.owner_id = t1.id) total_deposits
FROM users_customuser t1
GROUP BY t1.id
/*limits the script to transactions where counts are greater than 1*/
HAVING savings_count>=1
   AND investment_count >= 1
LIMIT 5;
