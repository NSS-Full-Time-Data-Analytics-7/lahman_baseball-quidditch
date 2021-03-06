--Question 1
SELECT min(yearid) AS earliest_year, max(yearid) AS latest_year
FROM teams;

--Question 2: Find the shortest player in the database.  What team did he play for?
SELECT DISTINCT CONCAT(p.namefirst, ' ', p.namelast) AS player_name , t.name AS team, a.g_all AS "Games Played"
FROM people AS p
JOIN appearances AS a
ON p.playerid=a.playerid
JOIN teams AS t
ON a.teamid=t.teamid
WHERE height =
	(SELECT MIN(height)
	FROM people);

--Question 3: Find players who played at Vanderbilt.  Show full name & salary earned.  Sort DESC by salary earned.
SELECT CONCAT(p.namefirst, ' ', p.namelast) AS name, (SUM(s.salary)::numeric)::money AS total_salary
FROM people AS p
LEFT JOIN salaries AS s
ON p.playerid=s.playerid
JOIN collegeplaying AS c
ON p.playerid=c.playerid
JOIN schools AS sch
ON c.schoolid=sch.schoolid
WHERE sch.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC NULLS LAST;


--Question 4: Group players based on their position as Outfield, Infield, or Battery
SELECT CASE
	   WHEN f.pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
	   WHEN f.pos = 'OF' THEN 'Outfield'
	   WHEN f.pos IN ('P', 'C') THEN 'Battery' END AS position,
	   SUM(po) AS putouts
FROM fielding AS f
WHERE yearid = 2016
GROUP BY position;

--Question 5: Find average # of Ks/game AND HRs/game by decade since 1920.
--Ks per game & HRs per game
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
	   ROUND((AVG(t.so))/(AVG(t.g)),2) AS "KOs/game",
	   ROUND((AVG(t.hr))/(AVG(t.g)),2) AS "HRs/game"
FROM teams AS t
WHERE yearid > 1919
GROUP BY decade
ORDER BY decade;



--Question 6:  Find highest successful stolen base percentage among players with at least 20 attempts.
--Stolen Base Percentage = sb / (sb + cs)
SELECT CONCAT(p.namefirst, ' ',  p.namelast) AS name,
	   ROUND((AVG(sb) / AVG(sb + cs)),3) * 100 AS sb_percentage
FROM batting
JOIN people AS p
ON batting.playerid=p.playerid
WHERE yearid = 2016 AND (sb + cs) >= 20
GROUP BY p.namefirst, p.namelast
ORDER BY sb_percentage DESC;

--Question 7: Since 1970, what is the most wins for a team that didn't win the World Series.  What is the least amount of wins for a team that did win the World Series?  
--Also, what is the least amount of wins for World Series winner other than lockout season.

--Most Regular season wins w/o winning world series
SELECT yearid, name, MAX(t.w) AS most_wins_wo_ws
FROM teams AS t
WHERE yearid > 1969 AND t.wswin = 'N'
GROUP BY yearid, name
ORDER BY most_wins_wo_ws DESC;

--Least Regular seasons wins as world series champions
SELECT yearid, name, MIN(t.w) AS most_wins_wo_ws
FROM teams AS t
WHERE yearid > 1969 AND t.wswin = 'Y'
GROUP BY yearid, name
ORDER BY most_wins_wo_ws;

--Least Regular seasons wins as world series champions in non-lockout season
SELECT yearid, name, MIN(t.w) AS most_wins_wo_ws
FROM teams AS t
WHERE yearid > 1969 AND yearid <> 1981 AND t.wswin = 'Y'
GROUP BY yearid, name
ORDER BY most_wins_wo_ws;

--Percentage of time teams w/ most wins won World Series
WITH sub AS (SELECT yearid,  MAX(t.w) AS most_wins
			FROM teams AS t
			WHERE yearid > 1969 
			GROUP BY yearid
			ORDER BY yearid DESC)
SELECT (ROUND(COUNT(DISTINCT teams.yearid)::decimal * 100, 2) / 47) AS "% of teams w/ most wins won World Series "
FROM sub
INNER JOIN teams USING (yearid) 
WHERE w = most_wins AND wswin ='Y' 

--Question 8: Find teams and parks which had top 5 AVG attendance AND bottom 5 lowest attendance in 2016
--TOP 5
SELECT homegames.team, parks.park_name AS park_name, (homegames.attendance / homegames.games) AS avg_attendance
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
GROUP BY homegames.team, parks.park_name,homegames.attendance, homegames.games
HAVING games > 9
ORDER BY avg_attendance DESC
LIMIT 5;

--BOTTOM 5
SELECT homegames.team, parks.park_name AS park_name, (homegames.attendance / homegames.games) AS avg_attendance
FROM homegames INNER JOIN parks USING(park)
WHERE year = 2016
GROUP BY homegames.team, parks.park_name,homegames.attendance, homegames.games
HAVING games > 9
ORDER BY avg_attendance
LIMIT 5;


--Question 9:  Which managers have won the TSN manager of the year award in the NL & AL.  Give full name and teams they were managing when they won the award
SELECT DISTINCT CONCAT(p.namefirst, ' ', p.namelast) AS manager_name, m.teamid AS team, aw.lgid AS league, aw.yearid AS year
FROM people AS p
JOIN managers AS m USING (playerid)
JOIN awardsmanagers AS aw USING (playerid, yearid) 
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

--Question 10:  Find all players who hit their career highest # of HRs in 2016.  Consider only players who have played at least 10 years.
SELECT CONCAT(p.namefirst, ' ', p.namelast) AS "Player name", MAX(b.hr) AS career_high_hrs
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

--Question 11: Any correlation between # of wins and team salary? Use data from 2000 and later. May want to look on a year by year basis.
SELECT t.yearid, t.name, t.w, (SUM(s.salary)::numeric)::money
FROM teams AS t
JOIN salaries AS s USING (teamid, yearid)
WHERE t.yearid >= 2000
GROUP BY t.yearid, t.name, t.w
ORDER BY t.yearid, t.name



--Question 12: Any correlation between # of wins and home attendance? Do teams who win the world series see a boost in attendance the following year?


--Question 13: How rare are left handed pitchers compared to right handed pitches? Are lefties more likely to win the Cy Young Award?  More like to make HOF?

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



