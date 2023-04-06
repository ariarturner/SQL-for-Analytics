/*
------------------------------------
-- Top improved adoption quarters --
------------------------------------

Create a report that shows the top 5 most improved quarters in terms of the number of adoptions, both per species, and overall.
Improvement means the increase in number of adoptions compared to the previous calendar quarter.
The first quarter in which animals were adopted for each species and for all species, does not constitute an improvement from zero, and should be treated as no improvement.
In case there are quarters that are tied in terms of adoption improvement, return the most recent ones.

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/iXNVJBk3?hide=8

*/

-- using start date to define quarters
WITH adoption_quarters AS (
SELECT 	Species,
	MAKE_DATE(CAST(DATE_PART ('year', adoption_date) AS INT),
		CASE 
			WHEN DATE_PART ('month', adoption_date) < 4 THEN 1
			WHEN DATE_PART ('month', adoption_date) BETWEEN 4 AND 6 THEN 4
			WHEN DATE_PART ('month', adoption_date) BETWEEN 7 AND 9 THEN 7
			WHEN DATE_PART ('month', adoption_date) > 9 THEN 10
		END, 
        1
	) AS quarter_start
FROM adoptions
),
-- looking at quarterly adoptions by species and for all species
quarterly_adoptions AS (
SELECT 	COALESCE(species, 'All species') AS species, quarter_start,
	COUNT (*) AS quarterly_adoptions,
    -- coalesce to get difference for first quarter (otherwise would show null)
	COUNT (*) - COALESCE(
		-- For quarters with no previous adoptions use 0, not NULL 
		FIRST_VALUE (COUNT (*))
		OVER (PARTITION BY species
			ORDER BY quarter_start ASC
			RANGE BETWEEN INTERVAL '3 months' PRECEDING 
				AND 
				INTERVAL '3 months' PRECEDING
			)
			, 0
	) 
	AS adoption_difference_from_previous_quarter,
	CASE 	
		WHEN quarter_start = FIRST_VALUE (quarter_start) 
			OVER (PARTITION BY species
				ORDER BY quarter_start ASC
					RANGE BETWEEN UNBOUNDED PRECEDING
						AND
						UNBOUNDED FOLLOWING
			)
		THEN 0
		ELSE NULL
	END AS zero_for_first_quarter
FROM adoption_quarters
GROUP BY GROUPING SETS ((quarter_start, species), (quarter_start))
),
-- rank quarters to get top improvement
quarterly_adoptions_with_rank AS (
SELECT 	*,
	RANK ()
	OVER (PARTITION BY species
			ORDER BY COALESCE (zero_for_first_quarter, adoption_difference_from_previous_quarter) DESC,
				-- First quarters are 0, all others NULL
				quarter_start DESC
		)
	AS quarter_rank
FROM 	quarterly_adoptions
)
-- get top quarters
SELECT 	species,
	CAST (DATE_PART ('year', quarter_start) AS INT) AS year,
	CAST (DATE_PART ('quarter', quarter_start) AS INT) AS quarter,
	adoption_difference_from_previous_quarter, quarterly_adoptions
FROM quarterly_adoptions_with_rank
WHERE quarter_rank <= 5
ORDER BY species ASC, adoption_difference_from_previous_quarter DESC, quarter_start ASC;
