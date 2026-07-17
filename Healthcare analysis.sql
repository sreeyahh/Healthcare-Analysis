create database HealthcareAnalysis

use HealthcareAnalysis

CREATE TABLE appointments(
    patient_id BIGINT,
    appointment_id BIGINT PRIMARY KEY,
    gender VARCHAR(10),
    scheduled_date DATETIME,
    appointment_date DATETIME,
    age INT,
    neighbourhood VARCHAR(100),
    scholarship INT,
    hypertension INT,
    diabetes INT,
    alcoholism INT,
    handicap INT,
    sms_received INT,
    no_show VARCHAR(5),
    appointment_status VARCHAR(20),
    waiting_days INT,
    appointment_weekday VARCHAR(20),
    age_group VARCHAR(20)
);

select * from appointments

BULK INSERT appointments
FROM '/var/opt/mssql/data/healthcare_cleaned.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
);

USE HealthcareAnalysis



ALTER TABLE appointments 
ALTER COLUMN patient_id DECIMAL(18, 1);

ALTER TABLE appointments
ALTER COLUMN no_show VARCHAR(20);

ALTER TABLE appointments
ALTER COLUMN gender VARCHAR(20);

ALTER TABLE appointments
ALTER COLUMN neighbourhood VARCHAR(200);

ALTER TABLE appointments
ALTER COLUMN appointment_status VARCHAR(50);

ALTER TABLE appointments
ALTER COLUMN appointment_weekday VARCHAR(50);

ALTER TABLE appointments
ALTER COLUMN age_group VARCHAR(50);

truncate table appointments

drop table appointments

CREATE TABLE appointments (
    patient_id DECIMAL(18,1),
    appointment_id BIGINT PRIMARY KEY,
    gender VARCHAR(10),
    scheduled_date DATETIME,
    appointment_date DATETIME,
    age INT,
    neighbourhood VARCHAR(100),
    scholarship INT,
    hypertension INT,
    diabetes INT,
    alcoholism INT,
    handicap INT,
    sms_received INT,
    no_show VARCHAR(20)
);

BULK INSERT appointments
FROM '/var/opt/mssql/data/healthcare_cleaned.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);

select count(*) as total_records from appointments

select top 10 * from appointments

select count(*) as total_appointments from appointments

SELECT COUNT(*) AS no_show_count
FROM appointments
WHERE no_show = 'Yes';

SELECT COUNT(*) AS attended_count
FROM appointments
WHERE no_show = 'No';

SELECT 
    ROUND(
        COUNT(CASE WHEN no_show='Yes' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS no_show_percentage
FROM appointments;

SELECT 
    gender,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS no_show_percentage
FROM appointments
GROUP BY gender;

ALTER TABLE appointments
ADD age_group varchar(20)

UPDATE appointments
SET age_group =
CASE
    WHEN age < 18 THEN 'Child'
    WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN age BETWEEN 36 AND 60 THEN 'Adult'
    ELSE 'Senior'
END;

select top 10 * from appointments

SELECT
    sms_received,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS no_show_percentage
FROM appointments
GROUP BY sms_received;

ALTER TABLE appointments
ADD waiting_days INT
update appointments set waiting_days= datediff(DAY, scheduled_date, appointment_date);

SELECT avg(waiting_days) as avg_waiting_days from appointments

SELECT
    waiting_days,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END)*100.0/COUNT(*),
        2
    ) AS no_show_percentage
FROM appointments
GROUP BY waiting_days
ORDER BY waiting_days;

SELECT patient_id, scheduled_date, appointment_date, waiting_days from appointments where waiting_days<0;

SELECT
    waiting_days,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS no_show_percentage
FROM appointments
WHERE waiting_days >= 0
GROUP BY waiting_days
ORDER BY waiting_days;

SELECT
    YEAR(appointment_date) AS year,
    MONTH(appointment_date) AS month,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY
    YEAR(appointment_date),
    MONTH(appointment_date)
ORDER BY
    year,
    month;

select datename(weekday, appointment_date) as weekday, count(*) as total_appointments from appointments
group by datename(weekday, appointment_date)
order by total_appointments desc

SELECT
    DATEPART(HOUR, scheduled_date) AS scheduled_hour,
    COUNT(*) AS total_scheduled
FROM appointments
GROUP BY DATEPART(HOUR, scheduled_date)
ORDER BY scheduled_hour;

SELECT
    hypertension,
    diabetes,
    alcoholism,
    handicap,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows
FROM appointments
GROUP BY
    hypertension,
    diabetes,
    alcoholism,
    handicap
ORDER BY total_patients DESC;

SELECT
    age_group,
    AVG(age) AS average_age,
    COUNT(*) AS total_patients
FROM appointments
GROUP BY age_group;

SELECT TOP 10
    neighbourhood,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY neighbourhood
ORDER BY total_appointments DESC;

SELECT
    neighbourhood,
    COUNT(*) AS total_appointments,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS neighbourhood_rank
FROM appointments
GROUP BY neighbourhood;

WITH neighbourhood_summary AS
(
    SELECT
        neighbourhood,
        COUNT(*) AS total_appointments
    FROM appointments
    GROUP BY neighbourhood
)

SELECT *
FROM neighbourhood_summary
WHERE total_appointments > 2000
ORDER BY total_appointments DESC;

SELECT
    CASE
        WHEN waiting_days = 0 THEN 'Same Day'
        WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
        WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
        ELSE '15+ Days'
    END AS waiting_bucket,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows
FROM appointments
WHERE waiting_days >= 0
GROUP BY
    CASE
        WHEN waiting_days = 0 THEN 'Same Day'
        WHEN waiting_days BETWEEN 1 AND 7 THEN '1-7 Days'
        WHEN waiting_days BETWEEN 8 AND 14 THEN '8-14 Days'
        ELSE '15+ Days'
    END
ORDER BY total_patients DESC;

SELECT TOP 10
    neighbourhood,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS no_show_rate
FROM appointments
GROUP BY neighbourhood
HAVING COUNT(*) >= 50
ORDER BY no_show_rate DESC;

SELECT
    gender,
    AVG(waiting_days) AS avg_waiting_days
FROM appointments
WHERE waiting_days >= 0
GROUP BY gender;

SELECT
    age_group,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN no_show='No' THEN 1 ELSE 0 END) AS attended,
    SUM(CASE WHEN no_show='Yes' THEN 1 ELSE 0 END) AS missed
FROM appointments
GROUP BY age_group;

SELECT
    appointment_date,
    COUNT(*) AS daily_appointments,
    SUM(COUNT(*)) OVER (
        ORDER BY appointment_date
    ) AS running_total
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date;

