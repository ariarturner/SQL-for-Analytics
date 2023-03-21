/* 
----------------------------------------------------
-- Framing Examples --
----------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/3H-puUMT?hide=24576
*/

-- Count up-to-previous day number of animals of the same species
-- again subquery is an unoptimized approach

SELECT 	a1.species, 
	a1.name, 
	a1.primary_color, 
	a1.admission_date,
	(	SELECT 	COUNT (*) 
		FROM 	animals AS a2
		WHERE 	a2.species = a1.species
				AND
				a2.admission_date < a1.admission_date
	) AS up_to_previous_day_species_animals
FROM 	animals AS a1
ORDER BY 	a1.species ASC,
		a1.admission_date ASC
;

-- using window function and partition; easier to read an optimized
-- Partition allows window to view only records with the same value as current row
-- since between is inclusive, this includes current row's admission date (rather than up to previous day)

SELECT 	species, 
	name, 
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	 (	PARTITION BY species
			ORDER BY admission_date ASC
			ROWS BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					CURRENT ROW
		 ) AS up_to_previous_day_species_animals
FROM 	animals
ORDER BY 	species ASC,
		admission_date ASC
;

-- Subquery modified to match window function solution, but this does not accurately answer the question
SELECT 	a1.species, 
	a1.name, 
	a1.primary_color, 
	a1.admission_date,
	(	SELECT 	COUNT (*) 
		FROM 	animals AS a2
		WHERE 	a2.species = a1.species
			AND
			a2.admission_date <= a1.admission_date
	) AS up_to_today_species_animals
FROM 	animals AS a1
ORDER BY 	a1.species ASC,
		a1.admission_date ASC
;

-- Attempted solution using partition
-- Since days may be unconsecutive, using ROWS as frame type is not correct and will not account for that

SELECT 	species, 
	name, 
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	(	PARTITION BY species
			ORDER BY 	admission_date ASC
			ROWS BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					1 PRECEDING
		) AS up_to_previous_day_species_animals
FROM 	animals
ORDER BY 	species ASC, 
		admission_date ASC
;


-- To narrow down investigation into why this is misaligned:

-- Animals of the same species admitted on the same day
SELECT 	species, 
	admission_date, 
	COUNT (*)
FROM 	animals
GROUP BY 	species, 
		admission_date 
HAVING 	COUNT (*) > 1;

-- Which animals are they?
SELECT 	*
FROM 	animals
WHERE 	admission_date = '2017-08-29';

-- Focus on King and Prince
-- subquery makes it difficult to read

SELECT 	a1.species, 
	a1.name, 
	a1.primary_color, 
	a1.admission_date,
	(	SELECT 	COUNT (*) 
		FROM 	animals AS a2
		WHERE 	a2.species = a1.species
			AND
			a2.admission_date < a1.admission_date
			AND
			a2.species = 'Dog' 
			AND 
			a2.admission_date > '2017-08-01'
	) AS up_to_previous_day_species_animals
FROM 	animals AS a1
WHERE 	a1.species = 'Dog' 
	AND 
	a1.admission_date > '2017-08-01'
ORDER BY 	a1.species ASC, 
		a1.admission_date ASC
;

-- replace subquery with CTE for clarity
WITH filtered_animals AS
( 	SELECT 	*
	FROM 	animals
	WHERE 	species = 'Dog' 
		AND 
		admission_date > '2017-08-01')
SELECT 	fa1.species, fa1.name, 
		fa1.primary_color, fa1.admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	filtered_animals AS fa2
			WHERE 	fa2.species = fa1.species
				AND
				fa2.admission_date < fa1.admission_date
		) AS up_to_previous_day_species_animals
FROM 	filtered_animals AS fa1
ORDER BY 	fa1.species ASC, 
		fa1.admission_date ASC
;

-- ROWS 1 PRECEDING
-- can see results don't line up with the CTE/subquery solution
SELECT 	species,
	name,
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	(	PARTITION BY 	species
			ORDER BY 	admission_date ASC
			ROWS BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					1 PRECEDING
		) AS up_to_yesterday_species_animals
FROM 	animals
WHERE 	species = 'Dog' 
	AND 
	admission_date > '2017-08-01'
ORDER BY 	species ASC, 
		admission_date ASC
;

-- RANGE 1 PRECEDING
-- this throws an error because we need to include units with date data types
SELECT 	species,
	name, 
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	(	PARTITION BY 	species
			ORDER BY 	admission_date ASC
			RANGE BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					1 PRECEDING
		) AS up_to_previous_day_species_animals
FROM 	animals
WHERE 	species = 'Dog' 
	AND 
	admission_date > '2017-08-01'
ORDER BY 	species ASC, 
		admission_date ASC;
    
-- RANGE 1 PRECEDING Fixed
-- specify 1 day for range and this fixes the issue

SELECT 	species,
	name, 
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	(	PARTITION BY 	species
			ORDER BY 	admission_date ASC
			RANGE BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					'1 Day' PRECEDING
		) AS up_to_previous_day_species_animals
FROM 	animals
WHERE 	species = 'Dog' 
	AND 
	admission_date > '2017-08-01'
ORDER BY 	species ASC, 
		admission_date ASC;
    
    
-- Okay returning to the initial question: count up-to-previous day number of animals of the same species
-- Using a partition and RANGE to optimize the query

SELECT 	species, 
	name, 
	primary_color, 
	admission_date,
	COUNT (*) 
	OVER 	(	PARTITION BY species
			ORDER BY 	admission_date ASC
			RANGE BETWEEN 	UNBOUNDED PRECEDING 
					AND 
					'1 day' PRECEDING
		) AS up_to_previous_day_species_animals
FROM 	animals
ORDER BY 	species ASC, 
		admission_date ASC
;
