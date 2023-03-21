/* 
----------------------------------------------------
-- Partition Examples --
----------------------------------------------------

Note: This uses the animal shelter database (https://github.com/ariarturner/SQL-for-Analytics/blob/main/Animal%20Shelter/Animal_Shelter_DB_and_Data.sql).
https://dbfiddle.uk/US9TljN5?hide=64
*/

-- list of animals with the number of animals with the same species
-- using a subquery there are performance issues because subquery has to execute for each record
-- self joins are inefficient

SELECT 	a1.species, 
		a1.name, 
		a1.primary_color, 
		a1.admission_date,
		(	SELECT 	COUNT (*) 
			FROM 	animals AS a2
			WHERE 	a2.species = a1.species
		) AS number_of_species_animals
FROM 	animals AS a1
ORDER BY 	a1.species ASC, 
			a1.admission_date ASC
;

-- another version of using a subquery that's more optimized
SELECT 	a.species, 
		a.name, 
		a.primary_color, 
		a.admission_date,
		species_counts.number_of_species_animals
FROM 	animals AS a
		INNER JOIN 
		(	SELECT 	species,
					COUNT(*) AS number_of_species_animals
			FROM 	animals
			GROUP BY species
		) AS species_counts
		ON a.species = species_counts.species
ORDER BY 	a.species ASC,
			a.admission_date ASC
;

-- using a window function, and PARTITION BY clause, we can specify that we only want the window to see other records with the same value as the current row

SELECT 	species,
		name,
		primary_color,
		admission_date,
		COUNT (*) 
		OVER (PARTITION BY species) AS number_of_species_animals
FROM 	animals
ORDER BY 	species ASC, 
			admission_date ASC
-- LIMIT 10
;
