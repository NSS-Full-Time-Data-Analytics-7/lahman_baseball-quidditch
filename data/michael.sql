SELECT *
FROM people;

/*Q1. What range of years for baseball games played does the provided database cover?*/
SELECT MAX(yearid) AS recent_year,
	   MIN(yearid) AS oldest_year
FROM teams;

---Q2 ~berhan's code
SELECT  people.namefirst AS first_name, people.namelast AS last_name, teams.name AS team, ap.g_all AS games_played, people.height 
FROM appearances AS ap  INNER JOIN teams ON ap.teamid = teams.teamid
INNER JOIN people ON ap.playerid = people.playerid
WHERE height  = 43
GROUP BY   first_name,last_name, people.height, teams.name, ap.g_all
ORDER BY people.height;

--Question 3: Find players who played at Vanderbilt.  Show full name & salary earned.  Sort DESC by salary earned.
-- Seth's code
SELECT p.namefirst AS "First Name", p.namelast AS "Last Name", (SUM(s.salary)::numeric)::money AS total_salary
FROM people AS p
JOIN salaries AS s
ON p.playerid=s.playerid
JOIN collegeplaying AS c
ON p.playerid=c.playerid
JOIN schools AS sch
ON c.schoolid=sch.schoolid
WHERE sch.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;

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

--Question 5: Find average # of Ks/game AND HRs/game by decade since 1920.
--Ks per game; Seth's code
SELECT CASE
		WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s' 
		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		WHEN yearid BETWEEN 2010 AND 2016 THEN '2010s' END AS decade,
	   ROUND((AVG(t.so))/(AVG(t.g)),2) AS Ks_per_game
FROM teams AS t
WHERE yearid > 1919
GROUP BY decade
ORDER BY decade;

--HRs per game; Seth's code
SELECT CASE
		WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s' 
		WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
		WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
		WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
		WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
		WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
		WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
		WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
		WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
		WHEN yearid BETWEEN 2010 AND 2016 THEN '2010s' END AS decade,
	   ROUND((AVG(t.hr))/(AVG(t.g)),2) AS hrs_per_game
FROM teams AS t
WHERE yearid > 1919
GROUP BY decade
ORDER BY decade;

/*Q8. Using the attendance figures from the homegames table, find the teams and parks 
which had the top 5 average attendance per game in 2016 (where average attendance is
defined as total attendance divided by number of games). Only consider parks where 
there were at least 10 games played. Report the park name, team name, and average attendance. 
Repeat for the lowest 5 average attendance.*/


SELECT homegames.team, parks.park_name AS park_id,homegames.park, (homegames.attendance / homegames.games) AS avg_attendance
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
GROUP BY homegames.team, homegames.park, parks.park_name,homegames.attendance, homegames.games
HAVING games > 9
ORDER BY avg_attendance
LIMIT 5;

/*Q10. Find all players who hit their career highest number of home runs in 2016. 
Consider only players who have played in the league for at least 10 years, 
and who hit at least one home run in 2016. Report the players' first and last names 
and the number of home runs they hit in 2016.*/
-- Use a window function to compare HR to MaxHR for each player and place in CTE

SELECT DISTINCT playerid, yearid, MAX(hr)
FROM batting
GROUP BY playerid, yearid
ORDER BY MAX(hr) DESC;


SELECT p.namefirst, p.namelast, b.yearid, ((p.finalgame::date)-(p.debut::date))/365 AS years_played
FROM people AS p INNER JOIN batting AS b USING(playerid); --calculated years played

WITH a AS (SELECT b.yearid, 
					  ((p.finalgame::date)-(p.debut::date))/365 AS years_played
					  FROM people AS p INNER JOIN batting AS b USING(playerid))
SELECT * 
FROM a 
WHERE years_played > 9



SELECT p.namefirst, p.namelast, MAX(hr) AS max_hr
FROM batting AS b INNER JOIN people AS p USING(playerid)
WHERE yearid = 2016
GROUP BY p.namefirst, p.namelast;


SELECT CONCAT(namefirst,' ',namelast)
FROM people;--CONCAT example






