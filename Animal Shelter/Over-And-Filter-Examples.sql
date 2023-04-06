/*
----------------------------------------------------
-- Over and Filter examples --
----------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/quc3yn1w?hide=4096
*/


/* 
OVER ()
*/

-- Retrieve list of animals
-- standard select, with no summarization
SELECT 	species, 
		name, 
		primary_color, 
		admission_date
FROM 	animals
ORDER BY admission_date ASC;

-- using a subquery to summarize total number of animals
-- not recommended because the subquery has to run for each record, which negatively impacts performance
SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT COUNT (*) 
			FROM animals
		) AS number_of_animals
FROM 	animals
ORDER BY admission_date ASC;

-- replacing subquery with a window function to improve performance
-- window function places a "window" over the animals table to count total number of records
SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		COUNT (*) 
		OVER () AS number_of_animals
FROM 	animals
ORDER BY admission_date ASC;


/*
FILTER
*/

-- Retrieve list of animals that were admitted after January 1, 2017
-- using subquery, again, same issue with performance
-- the subquery is filtered on admission date, so number of animals is based on admission date filter
-- main query is not filtered, so it returns list of all animals
SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	animals
			WHERE 	admission_date >= '2017-01-01'
		) AS number_of_animals
FROM 	animals
ORDER BY admission_date ASC;

-- in order to get list of animals admitted after January 1, 2017, we need to filter in the subquery and main query
-- again, performance issues
-- but also opens up more room for human error and makes it difficult to update queries
SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	animals
			WHERE 	admission_date >= '2017-01-01'
		) AS number_of_animals
FROM 	animals
WHERE 	admission_date >= '2017-01-01'
ORDER BY admission_date ASC;

-- we can filter on the window, so number of animals is based on admission date filter
-- main query is not filtered, so it returns list of all animals
SELECT 	species, 
		name, 
		primary_color, 
		admission_date,
		COUNT (*)
		FILTER (WHERE admission_date >= '2017-01-01')
		OVER () AS number_of_animals
FROM 	animals
ORDER BY admission_date ASC;

-- using a WHERE clause in the main query will also affect the window
-- main query returns only animals admitted after January 1, 2017
-- number of animals is also based on admission date filter
SELECT 	species,
		name, 
		primary_color, 
		admission_date,
		COUNT (*)
		OVER () AS number_of_animals
FROM 	animals	
WHERE 	admission_date >= '2017-01-01'
ORDER BY admission_date ASC;
