PROC IMPORT DATAFILE="/home/u64416841/bank-full.csv" /* import the dataset */
OUT=marketing
DBMS=CSV
REPLACE;
DELIMITER=';'; /* convert data from csv */
GETNAMES=YES;
RUN;


PROC CONTENTS DATA=marketing; /* checking if data is loaded fully */
RUN;
PROC PRINT DATA=marketing (OBS=10);
RUN;

PROC FREQ DATA=marketing; /* Overall marketing campaign response */
TABLES y;
RUN;

PROC SQL; /* Creating age groups for segmentation */
CREATE TABLE age_segment AS
SELECT 
    CASE 
        WHEN age < 30 THEN 'Young'
        WHEN age BETWEEN 30 AND 50 THEN 'Middle'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN y='yes' THEN 1 ELSE 0 END) AS responders
FROM marketing
GROUP BY age_group;
QUIT; 

PROC PRINT DATA=age_segment;
RUN;

PROC SQL;
CREATE TABLE job_conversion AS
SELECT 
    STRIP(job) AS job_category,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN UPCASE(STRIP(y)) = 'YES' THEN 1 ELSE 0 END) AS responders,
    (SUM(CASE WHEN UPCASE(STRIP(y)) = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*))
        AS conversion_rate FORMAT=6.2
FROM marketing
GROUP BY STRIP(job)
ORDER BY conversion_rate DESC;
QUIT;


PROC PRINT DATA=job_response;
RUN;

PROC SQL; /* Personal loan impact on campaign response */
CREATE TABLE loan_response AS
SELECT 
    loan,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN y='yes' THEN 1 ELSE 0 END) AS responders
FROM marketing
GROUP BY loan;
QUIT;

PROC SQL; /* Housing loan VS Response */
CREATE TABLE housing_response AS
SELECT 
    housing,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN y='yes' THEN 1 ELSE 0 END) AS responders
FROM marketing
GROUP BY housing;
QUIT;

PROC MEANS DATA=marketing; /* Balance statistics for marketing analysis */
VAR balance;
RUN;

PROC SQL;
CREATE TABLE balance_segment AS
SELECT 
    CASE 
        WHEN balance < 0 THEN 'Negative Balance'
        WHEN balance BETWEEN 0 AND 5000 THEN 'Low Balance'
        ELSE 'High Balance'
    END AS balance_group,
    COUNT(*) AS customers,
    SUM(CASE WHEN y='yes' THEN 1 ELSE 0 END) AS responders
FROM marketing
GROUP BY balance_group;
QUIT;

/* 1) Customers without personal loans responded better

2) Housing loan status influenced campaign effectiveness

3) Higher balance customers showed higher conversion rates

4) Financial profiling helped identify high-value segments */

DATA marketing_age;
SET marketing;

IF age < 30 THEN age_group = "Young";
ELSE IF age <= 50 THEN age_group = "Middle";
ELSE age_group = "Senior";
RUN;













