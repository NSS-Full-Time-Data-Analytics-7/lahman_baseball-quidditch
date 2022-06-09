--Question 3: Find players who played at Vanderbilt.  Show full name & salary earned.  Sort DESC by salary earned.
SELECT DISTINCT p.namefirst, p.namelast, (SUM(s.salary)::numeric)::money AS total_salary
FROM people AS p
JOIN salaries AS s
ON p.playerid=s.playerid
JOIN collegeplaying AS c
ON p.playerid=c.playerid
JOIN schools AS sch
ON c.schoolid=sch.schoolid
WHERE sch.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC