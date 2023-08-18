-- Imported datasets from the csv file
SELECT * FROM carbon_emission.carbon_dioxide_emission;

-- Identifying any null sets in the each column of datasets

SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE carbonCountry IS NULL;

SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE Year IS NULL;

SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE Series IS NULL;

SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE Value IS NULL;

-- After making sure that there are no nulls in thr dataset, Moving to examine the smaller parts of the dataset
-- Including the range of the column "Year", distinct value of the column "Series", the range of the column "Value" with different conditions. 

SELECT DISTINCT Series
FROM carbon_emission.carbon_dioxide_emission;

SELECT MIN(Year), MAX(Year)
FROM carbon_emission.carbon_dioxide_emission;

SELECT MIN(Value), MAX(Value)
FROM carbon_emission.carbon_dioxide_emission
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)';

SELECT MIN(Value), MAX(Value)
FROM carbon_emission.carbon_dioxide_emission
WHERE Series = 'Emissions per capita (metric tons of carbon dioxide)';

-- Ater checking some smaller parts of my dataset, find out that the 'Series' column has 2 distinct values.
-- break these two values into two different tables so that can work with them easier. 


-- firstly,  created new table called 'emissions' for the series 'Emissions (thousand metric tons of carbon dioxide)'


CREATE TABLE emissions
(Country nvarchar(50),
Year int, 
Series nvarchar(100), 
Value float);

--  values from the 'Carbon_Emission' table where Series = 'Emissions (thousand metric tons of carbon dioxide)'
-- into the 'emissions' table that I just create.

INSERT INTO emissions
SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE Series = 'Emissions (thousand metric tons of carbon dioxide)';

SELECT * FROM emissions;

-- Next,  created new table called 'perCapital' for the series Emissions per capita (metric tons of carbon dioxide) --- 

CREATE TABLE perCapital
(Country nvarchar(50),
Year int, 
Series nvarchar(100), 
Value float);

-- Insert values from the 'Carbon_Emission' table where Series = 'Emissions per capita (metric tons of carbon dioxide)'
-- into the 'perCapital' table that just create

INSERT INTO perCapital
SELECT * FROM carbon_emission.carbon_dioxide_emission
WHERE Series = 'Emissions per capita (metric tons of carbon dioxide)';

-- Now, exploring perCapital table first 


SELECT * FROM perCapital;

--  find the data about only America. 


SELECT DISTINCT Country
FROM perCapital
WHERE COUNTRY LIKE 'U%' ;

-- find countries that start with the letter U since there are many names for America, 

-- next, find the min and max value of Carbon Emissions per capital in America


SELECT MIN(Value) as min_value, MAX(Value) as Max_value FROM perCapital
WHERE Country = 'United States of America';
-- The min value is 14.606 and the max value is 20.168

SELECT Year FROM perCapital
WHERE Country = 'United States of America' AND Value IN (20.168, 14.606);
-- the year for the max value is 1975 and the year for the min value is 2017.

-- next, know the changes of emissions per capital in 2017 compared to the changes of emissions per capital in 1975 --- 


WITH value1975 AS (
    SELECT Country, Value AS old_value
    FROM perCapital
    WHERE Year = 1975
),
value2017 AS (
    SELECT Country, Value AS new_value
    FROM perCapital
    WHERE Year = 2017
)
SELECT *
FROM value1975
JOIN value2017 ON value1975.Country = value2017.Country;


SELECT DISTINCT pc.Country, ROUND((vc2017.new_value - vc1975.old_value) / vc1975.old_value, 2) AS changes 
FROM (
    SELECT Country, Value AS old_value
    FROM perCapital
    WHERE Year = 1975
) AS vc1975
INNER JOIN (
    SELECT Country, Value AS new_value
    FROM perCapital
    WHERE Year = 2017
) AS vc2017 ON vc1975.Country = vc2017.Country
INNER JOIN perCapital AS pc ON vc1975.Country = pc.Country
ORDER BY changes DESC;

 
-- Oman is the country that has the highest rate of increasing, which is 16.25. 
-- Dem. People's Rep. Korea has the lowest rate of decreasing, which is -0.84


-- now, with the emissions table

SELECT * FROM emissions;

--  the min and max value of America -- 

SELECT * FROM emissions
WHERE Country = 'United States of America';

SELECT MAX(Value), Min(Value)
FROM emissions
WHERE Country = 'United States of America';

SELECT * FROM emissions
WHERE Value = 5703220.175 
OR Value = 4355839.181 ; 
-- 2005 and 1975
-- finally, find out which 5 countries have the highest amount of carbon emissions

SELECT Country, SUM(Value) AS sum_value
FROM emissions
GROUP BY Country
ORDER BY sum_value DESC
LIMIT 5;

-- China	46219585.0625,United States of America	39527776.5, India	10199848.90625, Russian Federation	9141272.125, Japan	8563346.1875