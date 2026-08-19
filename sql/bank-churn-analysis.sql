CREATE TABLE bank_churn(
 Customer_id VARCHAR(6),
 Age INT,
 Gender VARCHAR(10),
 Country VARCHAR(20),
 Credit_Score INT,
 Tenure_Years INT,
 Balance NUMERIC(12,2),
 Num_Products INT,
 Has_credit_card SMALLINT,
 Is_Active_member SMALLINT,
 Estimated_salary NUMERIC(12,2),
 Num_transactions INT,
 Avg_transaction_value NUMERIC(10,2),
 Loan_amount NUMERIC(12,2),
 Loan_status VARCHAR(16),
 Satisfaction_score INT,
 Complaints_last_year INT,
 Account_type VARCHAR(10),
 Join_year INT,
 Churned SMALLINT
 );

 SELECT* FROM bank_churn;
 select count(*)
 from bank_churn;

 --checking how many tables are in this database
 SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

INSERT INTO bank_churn
SELECT *
FROM [banking churn dataset];

CREATE TABLE bank_customers(
customer_id varchar(6) PRIMARY KEY,
age INT,
gender VARCHAR(10),
country VARCHAR(20),
credit_score INT,
estimated_salary NUMERIC(12,2),
join_year INT
);

CREATE TABLE bank_accounts(
customer_id varchar(6) primary key references bank_customers(customer_id),
account_type varchar(10),
balance numeric (12,2),
tenure_years int,
num_products int
);

CREATE TABLE bank_loans(
customer_id varchar(6) primary key references bank_customers(customer_id),
loan_amount numeric (12,2),
loan_status varchar (16)
);

CREATE TABLE bank_transactions(
customer_id varchar(6) primary key references bank_customers(customer_id),
num_transactions int,
avg_transactions_value numeric (10,2)
);

CREATE TABLE bank_churn_profile(
customer_id varchar(6) primary key references bank_customers(customer_id),
satisfaction_score int,
complaint_last_year int,
is_active_member smallint,
has_credit_card smallint,
churned smallint
);

INSERT INTO bank_customers(customer_id, age, gender, country,credit_score,estimated_salary,join_year)
select 
Customer_id,
Age,
Gender,
Country,
Credit_score,
Estimated_salary,
Join_year
from bank_churn;

select* from bank_customers;

INSERT INTO bank_accounts(customer_id, account_type, balance, tenure_years, num_products)
select
Customer_id, Account_type, Balance, Tenure_years, Num_products
from bank_churn;

INSERT INTO bank_loans(customer_id, loan_amount, loan_status)
select
Customer_id, Loan_amount, Loan_status
from bank_churn;

INSERT INTO bank_transactions(customer_id, num_transactions, avg_transactions_value)
select
Customer_id, Num_transactions, Avg_transaction_value
from bank_churn;

select* from bank_transactions;

INSERT INTO bank_churn_profile(customer_id, satisfaction_score, complaint_last_year, is_active_member,has_credit_card,churned)
select
Customer_id, Satisfaction_score, Complaints_last_year, Is_Active_member, Has_credit_card, Churned
from bank_churn;

select * from bank_customers
where country = 'USA';

--Arithmetic
select customer_id, estimated_salary,
estimated_salary/12 as monthly_salary
from bank_customers;

--Aggregations
select count(*) as total_customers
from bank_customers;

 --
select country, count(customer_id) as total_customers
from bank_customers
group by country
having count(customer_id) > 150;

  --Total Customers
select  count(*) as total_customers
from bank_customers;

  --Average Customer Age
select avg(age) as avg_age
from bank_customers;

  --Male vs Female Customers
select gender, count(customer_id)
from bank_customers
group by gender;

select *
from bank_churn_profile;

  --Churned Percentage
SELECT 
    SUM(churned) * 100.0 / COUNT(*) AS churned_percentage
FROM bank_churn;

SELECT SUM(churned)
FROM bank_churn;

SELECT COUNT(*)
FROM bank_churn;

  --Churn rate by Country
select country, sum(churned) * 100.0 / COUNT(*) as churned_percentage 
from bank_customers
inner join bank_churn_profile
on bank_customers.customer_id = bank_churn_profile.customer_id
group by country
order by churned_percentage desc;

  --Churn rate by Age Group
SELECT 
    CASE 
        WHEN bc.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN bc.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN bc.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN bc.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,

    COUNT(*) AS total_customers,

    SUM(CASE WHEN bcp.churned = 1 THEN 1 ELSE 0 END) AS churned_customers,

    SUM(CASE WHEN bcp.churned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS churn_rate_pct

FROM bank_customers bc
JOIN bank_churn_profile bcp
    ON bc.customer_id = bcp.customer_id

GROUP BY 
    CASE 
        WHEN bc.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN bc.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN bc.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN bc.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END
ORDER BY churn_rate_pct DESC;

  --Average balance(Churned vs Non_Churned Customers)
select churned, avg(balance) as avg_balance
from bank_accounts
left join bank_churn_profile
on bank_accounts.customer_id =bank_churn_profile.customer_id
group by churned;

  --Total Money at risk
SELECT 
    SUM(Balance) AS lost_deposits,
    SUM(Loan_amount) AS lost_loans,
    SUM(Avg_transaction_value * Num_transactions) AS lost_transaction_value,
    
    SUM(
        Balance 
        + Loan_amount 
        + (Avg_transaction_value * Num_transactions)
    ) AS total_money_at_risk

FROM bank_churn
WHERE Churned = 1;

select * from bank_loans;

 --Churned customers with active loans
SELECT COUNT(*) AS churned_customers_with_active_loans
FROM bank_loans bl
JOIN bank_churn bc
    ON bl.customer_id = bc.customer_id
WHERE bl.loan_status = 'Active'
  AND bc.churned = 1;

  --Customer satisfaction Analysis
  select avg(satisfaction_score) as avg_satisfaction_score,churned
  from bank_churn_profile
  group by churned;

  --Highest risk Customers
  SELECT 
    customer_id,
    Age,
    Country,
    Balance,
    Loan_amount,
    Satisfaction_score,
    Complaints_last_year,
    Is_Active_member,
    Num_transactions
FROM bank_churn
WHERE 
    Churned = 1
    OR Satisfaction_score <= 3
    OR Complaints_last_year >= 2
    OR Is_Active_member = 0
ORDER BY 
    Satisfaction_score ASC,
    Complaints_last_year DESC,
    Balance DESC;

	--Transactions by Churned customers
SELECT 
    Churned,
    COUNT(*) AS total_customers,
    SUM(Num_transactions) AS total_transactions,
    AVG(Num_transactions) AS avg_transactions_per_customer
FROM bank_churn
GROUP BY Churned;

-- Highest churn rate by account type
SELECT 
    Account_type,
    COUNT(*) AS total_customers,
    SUM(Churned) AS churned_customers,
    AVG(Churned) * 100 AS churn_rate_pct
FROM bank_churn
GROUP BY Account_type
ORDER BY churn_rate_pct DESC;

 --Full customer view
 SELECT *
FROM bank_churn
ORDER BY balance DESC;
