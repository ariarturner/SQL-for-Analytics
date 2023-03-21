/* 
---------------------------------------------------------------
-- Combining Grouped and Window Aggregate Functions Examples --
---------------------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/BH_WayHU?hide=128
*/

/* GOAL: for each month of each year where there is an adoption, 
what is the month's total adoption fees and 
what percent of the year's total adoption fees is it?
*/

-- starting out just figuring out the monthly totals

SELECT	DATE_PART ('year', adoption_date) AS year,
	DATE_PART ('month', adoption_date) AS month,
	SUM (adoption_fee) AS month_total
FROM	adoptions
GROUP BY 	DATE_PART ('year', adoption_date), 
		DATE_PART ('month', adoption_date)
ORDER BY 	year ASC,
		month ASC
-- LIMIT 10
;


-- adding on annual percent
-- throws an error because adoption fee is not part of the group by clause and/or it's not used in an agg function

SELECT 	DATE_PART ('year', adoption_date) AS year,
	DATE_PART ('month', adoption_date) AS month,
	SUM (adoption_fee) AS month_total,
	CAST 	(100 * SUM (adoption_fee) 
		/	SUM (adoption_fee) 
			OVER (PARTITION BY DATE_PART ('year', adoption_date))
		AS DECIMAL (5, 2)
		) AS annual_percent
FROM 	adoptions
GROUP BY 	DATE_PART ('year', adoption_date), 
		DATE_PART ('month', adoption_date)
ORDER BY 	year ASC,
		month ASC;
    
    
-- can get around this by summing the sum, but this isn't very intuitive to read

SELECT 	DATE_PART ('year', adoption_date) AS year,
	DATE_PART ('month', adoption_date) AS month,
	SUM (adoption_fee) AS month_total,
	CAST	(100 *  SUM (adoption_fee) 
		/	SUM ( SUM (adoption_fee)) 
			OVER (PARTITION BY DATE_PART ('year', adoption_date)) 
		AS DECIMAL (5, 2)
		) AS annual_percent
FROM 	adoptions
GROUP BY 	DATE_PART ('year', adoption_date), 
		DATE_PART ('month', adoption_date)
ORDER BY 	year ASC,
		month ASC
;

-- or, for easier readability we can use a CTE

WITH monthly_grouped_adoptions
AS
(
SELECT 	DATE_PART ('year', adoption_date) AS year,
	DATE_PART ('month', adoption_date) AS month,
	SUM (adoption_fee) AS month_total
FROM 	adoptions
GROUP BY 	DATE_PART ('year', adoption_date), 
		DATE_PART ('month', adoption_date)
)
SELECT 	*,
	CAST 	(100 * month_total 
		 / 	SUM (month_total) 
			OVER (PARTITION BY year) 
		AS DECIMAL (5, 2)
		) AS annual_percent
FROM 	monthly_grouped_adoptions
ORDER BY 	year ASC,
		month ASC;
