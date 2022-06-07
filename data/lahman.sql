SELECT * FROM allstarfull;
SELECT * FROM appearances;
SELECT * FROM awardsmanagers;
SELECT * FROM awardsplayers;
SELECT * FROM awardssharemanagers;
SELECT * FROM awardsshareplayers
SELECT * FROM batting;
SELECT * FROM battingpost;
SELECT * FROM collegeplaying;
SELECT * FROM fielding;
SELECT * FROM fieldingof;
SELECT * FROM fieldingofsplit;
SELECT * FROM fieldingpost;
SELECT * FROM halloffame;
SELECT * FROM homegames;
SELECT * FROM managers;
SELECT * FROM managershalf;
SELECT * FROM parks;
SELECT * FROM people;
SELECT * FROM pitching;
SELECT * FROM pitchingpost;
SELECT * FROM salaries;
SELECT * FROM schools;
SELECT * FROM seriespost;
SELECT * FROM teams;
SELECT * FROM teamsfranchises;
SELECT * FROM teamshalf;


--Question 1
SELECT min(yearid) AS earliest_year, max(yearid) AS latest_year
FROM teams;

--Question 2: Find the shortest player in the database.  What team did he play for?
SELECT DISTINCT p.namefirst, p.namelast, t.name AS team
FROM people AS p
JOIN appearances AS a
ON p.playerid=a.playerid
JOIN teams AS t
ON a.teamid=t.teamid
WHERE height =
	(SELECT MIN(height)
	FROM people)

--Question 3: Find players who played at Vanderbilt.  Show full name & salary earned.  Sort DESC by salary earned.
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

--Question 4: Group players based on their position as Outfield, Infield, or Battery
SELECT CASE
	   WHEN f.pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	   WHEN f.pos = 'OF' THEN 'Outfield'
	   WHEN f.pos IN ('P', 'C') THEN 'Battery' END AS position,
	   SUM(po) AS putouts
FROM fielding AS f
WHERE yearid = 2016
GROUP BY position

--Question 5: Find average # of Ks/game AND HRs/game by decade since 1920.
--Ks per game
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
ORDER BY decade

--HRs per game
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
ORDER BY decade

--Question 6:  Find highest successful stolen base percentage among players with at least 20 attempts.
--Stolen Base Percentage = sb / (sb + cs)
SELECT p.namefirst AS "First Name", p.namelast AS "Last Name",
	   ROUND((AVG(sb) / AVG(sb + cs)),3) AS sb_percentage
FROM batting
JOIN people AS p
ON batting.playerid=p.playerid
WHERE yearid = 2016 AND (sb + cs) >= 20
GROUP BY p.namefirst, p.namelast
ORDER BY sb_percentage DESC





