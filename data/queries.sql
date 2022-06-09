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