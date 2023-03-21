/* 
----------------------------------------------------
-- Aggregate Window Functions Examples --
----------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/1RWJU2Pm?hide=256*/

-- Average species heart rates
SELECT 	species, 
	name,
	checkup_time, 
	heart_rate,
	CAST 	(
			AVG (heart_rate) 
			OVER (PARTITION BY species)
		AS DECIMAL (5, 2)
		) AS species_average_heart_rate
FROM	routine_checkups
ORDER BY 	species ASC,
		checkup_time ASC
;

-- Goal: List of animals who's heart rate is always greater than the species average

-- Nesting attempt
-- Error thrown because nesting isn't allowed with window functions

SELECT 	species, 
	name, 
	checkup_time, 
	heart_rate,
	EVERY 	(
		Heart_rate >= 	AVG (heart_rate) 
				OVER (PARTITION BY species)
		) 
		OVER (PARTITION BY species, name) AS consistently_at_or_above_average
FROM	routine_checkups
ORDER BY 	species ASC,
		checkup_time ASC;
    
    
-- Split with CTE
-- reminder: EVERY returns boolean

WITH species_average_heart_rates
AS
(
SELECT 	species,
	name, 
	checkup_time, 
	heart_rate, 
	CAST 	(
			AVG (heart_rate) 
			OVER (PARTITION BY species) 
		AS DECIMAL (5, 2)
		) AS species_average_heart_rate
FROM	routine_checkups
)
SELECT	species,
	name, 
	checkup_time, 
	heart_rate,
	EVERY 	(heart_rate >= species_average_heart_rate) 
	OVER 	(PARTITION BY species, name) AS consistently_at_or_above_average
FROM 	species_average_heart_rates
ORDER BY 	species ASC,
		checkup_time ASC
;


-- Use as filter attempt
-- Error thrown because window functions cannot be used in WHERE clauses

WITH species_average_heart_rates
AS
(
SELECT 	species, 
	name, 
	checkup_time, 
	heart_rate, 
	AVG (heart_rate) 
	OVER (PARTITION BY species) AS species_average_heart_rate
FROM	routine_checkups
)
SELECT	species, 
	name, 
	checkup_time, 
	heart_rate
FROM 	species_average_heart_rates
WHERE 	EVERY 	(heart_rate >= species_average_heart_rate) 
	OVER 	(PARTITION BY species, name)
ORDER BY 	species ASC,
		checkup_time ASC;
    
    
-- SOLUTION:
-- Separate into more CTEs
WITH species_average_heart_rates
AS
(
SELECT 	species, 
	name, 
	checkup_time, 
	heart_rate, 
    -- arithmetic aggregate function
	CAST 	(	AVG (heart_rate) 
			OVER (PARTITION BY species) 
		 AS DECIMAL (5, 2)
		 ) AS species_average_heart_rate
FROM	routine_checkups
),
with_consistently_at_or_above_average_indicator
AS
(
SELECT	species, 
	name, 
	checkup_time, 
	heart_rate,
	species_average_heart_rate,
    -- boolean aggregate function
	EVERY 	(heart_rate >= species_average_heart_rate) 
	OVER 	(PARTITION BY species, name) AS consistently_at_or_above_average
FROM 	species_average_heart_rates
)
SELECT 	DISTINCT species,
	name,
	heart_rate,
	species_average_heart_rate
FROM 	with_consistently_at_or_above_average_indicator
WHERE 	consistently_at_or_above_average
ORDER BY 	species ASC,
		heart_rate DESC;
