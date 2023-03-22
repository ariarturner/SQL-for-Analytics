/* 
----------------------------------------------------
-- Distribution Window Functions Examples --
----------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/qKlGHHsV?hide=32
*/

-- average weight
SELECT	species, 
	name, 
	CAST (AVG (weight) AS DECIMAL (5, 2)) AS average_weight
FROM 	routine_checkups
GROUP BY 	species, 
		name
ORDER BY 	species DESC, 
		average_weight DESC;
    
-- probability of any value
WITH average_weights
AS
(
SELECT	species, 
	name, 
	CAST (AVG (weight) AS DECIMAL (5, 2)) AS average_weight
FROM 	routine_checkups
GROUP BY 	species, 
		name
)
SELECT 	*,
  -- percent rank looks at the probability that a value is less than the current value, so the row with the minimum weight of each species will have a probability of 0 and the row with the maximum weight of each species will have a probability of 1
	PERCENT_RANK () 
	OVER (PARTITION BY species ORDER BY average_weight ASC) AS percent_rank,
  -- cume dist looks at the probability that a value is less than or equal to current value, so no rows will have a probability of 0 but the row with the maximum weight of each species will have a probability of 1
	CUME_DIST () 
	OVER (PARTITION BY species ORDER BY average_weight ASC) AS cumulative_distribtuion
FROM 	average_weights
ORDER BY 	species DESC, 
		average_weight DESC;
