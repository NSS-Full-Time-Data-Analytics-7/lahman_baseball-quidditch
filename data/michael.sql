SELECT *
FROM people;

/*Q1. What range of years for baseball games played does the provided database cover?*/
SELECT MAX(yearid) AS recent_year,
	   MIN(yearid) AS oldest_year
FROM teams;

/*Q4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three 
groups in 2016.*/

SELECT *
FROM fielding;

SELECT
	CASE WHEN pos = 'OF' THEN 'Outfield'
		 WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'
		 WHEN pos IN ('P','C') THEN 'Battery' END AS position, SUM(po) AS putouts
FROM fielding
WHERE yearid = 2016
GROUP BY position;