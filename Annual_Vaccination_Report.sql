/* 
----------------------------------------------------
-- Annual vaccinations report --
----------------------------------------------------

For all years in which animals were vaccinated, we want to know the total number of vaccinations given each year.
In addition, we want to know the average number of vaccinations given in the previous two years (two decimals),
and the percent difference between the current year's number of vaccinations and the average of the previous two years (two decimals).

Note: This uses the animal database.
*/

WITH yearly_vaccines AS (
SELECT DATE_PART('year', vaccination_time) AS year, COUNT(vaccine) AS number_of_vaccinations,
  CAST(AVG(COUNT(vaccine))
  OVER (
  ORDER BY DATE_PART('year', vaccination_time)
  RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING) AS DECIMAL (5,2)) AS previous_2_years_average
FROM vaccinations
GROUP BY year
ORDER BY year
  )

SELECT *, CAST(100 * (number_of_vaccinations / previous_2_years_average) - 1 AS DECIMAL (5,2)) AS percent_change
FROM yearly_vaccines
  ORDER BY year;