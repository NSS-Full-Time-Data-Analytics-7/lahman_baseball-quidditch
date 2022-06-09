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

--michael attempt on q3
WITH vandy AS (SELECT DISTINCT cp.playerid, s.schoolname
				FROM collegeplaying AS cp INNER JOIN schools AS s USING(schoolid)
				WHERE s.schoolname ILIKE '%vanderbilt%'),
	 s AS (SELECT playerid, salary::numeric::money AS salary
			   	FROM salaries)
SELECT CONCAT(p.namefirst, ' ',p.namelast), schools.schoolname, salary
FROM people AS p INNER JOIN vandy USING (playerid)
			INNER JOIN s USING (playerid)
			INNER JOIN collegeplaying AS cp USING (playerid)
			INNER JOIN schools USING (schoolid)
ORDER BY salary DESC; --attempt on q3

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

-- Top 5
SELECT homegames.team, parks.park_name,homegames.park AS park_id, (homegames.attendance / homegames.games) AS avg_attendance
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
GROUP BY homegames.team, homegames.park, parks.park_name,homegames.attendance, homegames.games
HAVING games > 9
ORDER BY avg_attendance DESC
LIMIT 5;

-- Bottom 5
SELECT homegames.team, parks.park_name,homegames.park AS park_id, (homegames.attendance / homegames.games) AS avg_attendance
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
GROUP BY homegames.team, homegames.park, parks.park_name,homegames.attendance, homegames.games
HAVING games > 9
ORDER BY avg_attendance
LIMIT 5;


--Q9. Seth's Code
--Question 9:  Which managers have won the TSN manager of the year award in the NL & AL.  
--Give full name and teams they were managing when they won the award
SELECT DISTINCT CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, m.teamid, aw.lgid, aw.yearid
FROM people AS p
JOIN managers AS m USING (playerid)
JOIN awardsmanagers AS aw USING (playerid)
WHERE playerid IN
	(WITH nl AS (SELECT p.playerid, aw.awardid, aw.lgid, aw.yearid
				FROM people AS p
				JOIN awardsmanagers AS aw ON p.playerid=aw.playerid
				WHERE aw.awardid LIKE 'TSN%' AND lgid = 'NL' 
				GROUP BY p.playerid, aw.awardid, aw.lgid, aw.yearid
				ORDER BY aw.yearid DESC),
	al AS 	    (SELECT p.playerid, aw.awardid, aw.lgid, aw.yearid
				FROM people AS p
				JOIN awardsmanagers AS aw ON p.playerid=aw.playerid
				WHERE aw.awardid LIKE 'TSN%' AND lgid = 'AL' 
				GROUP BY p.playerid, aw.awardid, aw.lgid, aw.yearid
				ORDER BY aw.yearid DESC)
	SELECT DISTINCT nl.playerid FROM nl
	JOIN al ON nl.playerid = al.playerid)
AND aw.yearid = m.yearid
GROUP BY p.namefirst, p.namelast, m.teamid, aw.lgid, aw.yearid
ORDER BY manager_name, aw.yearid

/*Q10. Find all players who hit their career highest number of home runs in 2016. 
Consider only players who have played in the league for at least 10 years, 
and who hit at least one home run in 2016. Report the players' first and last names 
and the number of home runs they hit in 2016.*/
-- Use a window function to compare HR to MaxHR for each player and place in CTE


WITH a AS (SELECT b.playerid,
		  ((p.finalgame::date)-(p.debut::date))/365 AS years_played
		  FROM people AS p INNER JOIN batting AS b USING(playerid)),
	 b AS (SELECT DISTINCT playerid, MAX(hr) AS most_hr
			FROM batting
			GROUP BY playerid)
SELECT DISTINCT CONCAT(p.namefirst,' ',p.namelast) AS player_name, hr AS home_runs
FROM a INNER JOIN b USING(playerid)
	   INNER JOIN people AS p USING (playerid)
	   INNER JOIN batting USING (playerid)
WHERE a.years_played > 9
	AND hr > 0
	AND yearid = 2016
	AND most_hr = hr
ORDER BY home_runs DESC;


--Seth's code for q10


SELECT CONCAT(p.namefirst, ' ', p.namelast) AS "Player name", MAX(b.hr)
FROM people AS p
JOIN batting AS b USING (playerid)
WHERE p.playerid IN
	--most career homeruns per player
	(WITH most AS (SELECT p.playerid, MAX(hr) AS most_hrs
				  FROM batting AS b
				  JOIN people AS p USING (playerid)
				  GROUP BY p.playerid
				  ORDER BY most_hrs DESC),
	 --homeruns per player in 2016
	sixteen AS (SELECT p.playerid, b.hr AS hr_2016
					FROM people AS p
					JOIN batting AS b USING (playerid)
					WHERE yearid = 2016
					ORDER BY b.hr DESC),
	a AS (SELECT b.playerid,
		 ((p.finalgame::date)-(p.debut::date))/365 AS years_played
		  FROM people AS p INNER JOIN batting AS b USING(playerid))
	SELECT DISTINCT most.playerid FROM most
	JOIN sixteen ON most.playerid = sixteen.playerid
	JOIN a ON sixteen.playerid = a.playerid
	WHERE most_hrs = hr_2016 AND years_played > 9 AND most.most_hrs > 0
	)
GROUP BY p.namefirst, p.namelast
ORDER BY MAX(b.hr) DESC;



/*SELECT CONCAT(namefirst,' ',namelast)
FROM people;--CONCAT example*/






