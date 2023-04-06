/*
------------------------------------------
-- Animals temperature exception report --
------------------------------------------

Create a report of the top 25% of animals per species that had the fewest “temperature exceptions”, ignoring animals that had no routine checkups.
A “temperature exception” is a checkup temperature measurement that is either equal to or exceeds +/- 0.5% from the species' average.
If two or more animals of the same species have the same number of temperature exceptions, those with the more recent exceptions should be returned.
There is no need to return additional tied animals over the 25% mark. If the number of animals for a species does not divide by 4 without remainder, you may
return 1 more animal, but not less.
The report should be sorted by species, number of exceptions, and latest exception timestamp.

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/yfNVWkwE?hide=16
*/

-- for each checkup, compare temp to avg species temp
WITH temp_diffs AS (
SELECT species,
	name,
	temperature,
	checkup_time,
	CAST(AVG(temperature) 
			OVER (PARTITION BY species) 
		AS DECIMAL (5,2)
		) AS species_avg_temp,
	CAST(temperature - AVG(temperature) 
					OVER (PARTITION BY species)
		AS DECIMAL (5, 2) 
		) AS diff_from_avg
FROM routine_checkups
),
-- create an indicator for temperature excpetions
exception_indicator AS (
SELECT	*,
	CASE 
		WHEN ABS(diff_from_avg / species_avg_temp) >= 0.005
		THEN 1
		ELSE 0
	END AS is_temp_exception
FROM temp_diffs
),
-- number of exceptions per animal
animal_exceptions AS (
SELECT species,
	name,
	SUM (is_temp_exception) AS num_exceptions,
	MAX (CASE 
			WHEN is_temp_exception = 1 
			THEN checkup_time
			ELSE NULL
			END
		) AS latest_exception
FROM exception_indicator
GROUP BY species, name
),
-- place animals into ntiles by number of exceptions for each species
exceptions_ntile AS (
SELECT 	*,
	NTILE (4)
	OVER (PARTITION BY species 
			ORDER BY num_exceptions ASC,
				 latest_exception DESC
		) AS ntile
FROM animal_exceptions
)
-- only look at the top ntile (top 25%)
SELECT species,
	name,
	num_exceptions,
	latest_exception
FROM exceptions_ntile
WHERE ntile = 1
ORDER BY species ASC,
		num_exceptions DESC,
		latest_exception DESC;
