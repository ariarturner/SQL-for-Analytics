/* 
----------------------------------------------------
-- Offset Window Function Examples --
----------------------------------------------------
Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/BDcwaB6h?hide=1048576  
*/

-- quick investigation of data
SELECT	species, 
	name,
	checkup_time,
	weight
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC
LIMIT 10;

/* ROW OFFSET WINDOW FUNCTIONS */

/* GOAL: Determine animal weight gain between checkups */

-- this results in NULLS for the first record of each animal - note offset is assumed to be 1 and default NULL
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight - LAG (weight) 
		 OVER 	(	 PARTITION BY species, name 
		 	 	 ORDER BY checkup_time ASC
		 	) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
    
-- this will give a data type error
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight - LAG (weight,1 , 'N/A') 
		 OVER 	(	PARTITION BY species, name 
			   	ORDER BY checkup_time ASC
			) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
-- as will this
SELECT	species, 
	name,
	checkup_time,
	weight,
	COALESCE 	(weight - 	LAG (weight) 
					OVER 	(	PARTITION BY species, name 
							ORDER BY checkup_time ASC
						)
			, 'N/A'
			) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
 
-- casting as varchar fixes data type issue, but loses ability to do numeric calculations
SELECT	species, 
	name,
	checkup_time,
	weight,
	COALESCE 	(CAST (100 * (weight - 	LAG (weight) 
						OVER 	(	PARTITION BY species, name 
								ORDER BY checkup_time ASC
							)
					) 
			AS VARCHAR(10)
			)
			, 'N/A'
			) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC,
		weight_gain ASC
LIMIT 10
;

-- automatically converts integer to float; but result is current weight, not weight gain
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight - 	LAG (weight, 1, 0) 
			OVER	(	PARTITION BY species, name 
			       		ORDER BY checkup_time ASC
			      	) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
    
-- adding an explicit offset and default results in weight_gain of 0.0 for first record; this is misleading because we don't actually know the weight gain, we just know current weight
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight -	LAG (weight, 1, 0.0) 
		 	OVER 	(	PARTITION BY species, name 
		 	   		ORDER BY checkup_time ASC
		 	  	) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;

-- using current weight as default results in 0 for weight gain, but this is misleading since we don't know the "initial" weight and can skew further processing this data
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight - 	LAG (weight, 1, weight) 
			OVER 	(	PARTITION BY species, name 
			 	   	ORDER BY checkup_time ASC
			 	) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
    

-- NULLS for the first record of each animal is the best option here
SELECT	species, 
	name,
	checkup_time,
	weight,
	weight - LAG (weight) 
		 OVER 	(	 PARTITION BY species, name 
		 	 	 ORDER BY checkup_time ASC
		 	) AS weight_gain
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC;
    

/* FRAME OFFSET WINDOW FUNCTIONS */

/* GOAL: weight change over last 3 months, sorted by greatest percent change first */

-- lots of zeros, but no nulls even though it's unlikely that each animal had multiple checkups in the last 3 months
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY checkup_time ASC
  -- note: frame is INCLUDING current row
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							CURRENT ROW
				)
	) AS weight_gain_since_up_to_3_months_ago
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC
;

-- now seeing nulls, but few values because timestamp is too specific
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY checkup_time ASC
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							'3 months' PRECEDING
				)
	) AS weight_gain_from_exactly_3_months_ago
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC
;

-- casting as date shows us that the timestamp was just too specific, as now we are seeing more values
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY CAST (checkup_time AS DATE) ASC
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							'3 months' PRECEDING
				)
	) AS weight_gain_from_3_months_ago_to_the_day
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC
;

-- looking at date rather than timestamp and ignoring the current value gives us a more accurate view of weight gain over the last 3 months
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY CAST (checkup_time AS DATE) ASC
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							'1 day' PRECEDING
				)
	) AS weight_gain_in_3_months
FROM 	routine_checkups
ORDER BY 	species ASC, 
		name ASC, 
		checkup_time ASC
;

-- we can't use functions in order by expressions on aliases in the same query
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY CAST (checkup_time AS DATE) ASC
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							'1 day' PRECEDING
				)
	) AS weight_gain_in_3_months
FROM 	routine_checkups
ORDER BY ABS (weight_gain_in_3_months) DESC;

-- solution is to put that in a CTE
WITH
weight_gains
AS
(
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight -	FIRST_VALUE (weight) 
			OVER 	(	PARTITION BY species, name 
					ORDER BY CAST (checkup_time AS DATE) ASC
					RANGE BETWEEN 	'3 months' PRECEDING 
							AND 
							'1 day' PRECEDING
				)
	) AS weight_gain_in_3_months
FROM 	routine_checkups
)
SELECT 	*
FROM 	weight_gains
-- put NULLS last so that we can see actual values first
ORDER BY ABS (weight_gain_in_3_months) DESC NULLS LAST
;


-- finally, let's find the percent change and sort it so we can focus on the animals with the most drastic changes
WITH
weight_gains
AS
(
SELECT	species, 
	name,
	checkup_time,
	weight,
	(weight - 	FIRST_VALUE (weight) 
			OVER (	PARTITION BY species, name 
				ORDER BY CAST (checkup_time AS DATE) ASC
				RANGE BETWEEN 	'3 months' PRECEDING 
						AND 
						'1 day' PRECEDING
				)
	) AS weight_gain_in_3_months
FROM 	routine_checkups
),
include_percentage
AS
(
SELECT 	*,
	CAST 	(100 * weight_gain_in_3_months / weight 
		 AS DECIMAL (5, 2)
		 ) AS percent_change
FROM 	weight_gains
)
SELECT 	*
FROM 	include_percentage
WHERE 	percent_change IS NOT NULL
ORDER BY ABS (percent_change) DESC
;
