SELECT *
FROM people;

/*What range of years for baseball games played does the provided database cover?*/
SELECT MAX(yearid) AS recent_year,
	   MIN(yearid) AS oldest_year
FROM teams;