-- COMP3311 17s1 Project 1
--
-- MyMyUNSW Solution Template


-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT Buildings.unswid, Buildings.name
FROM Buildings JOIN Rooms ON Buildings.id = Rooms.building
GROUP BY Buildings.unswid, Buildings.name
HAVING (COUNT (Rooms.building) > 30)
;



-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT people.name, OrgUnits.longname, Staff.phone, affiliations.starting
FROM people, affiliations, OrgUnits, Staff, staff_roles
WHERE staff.id = people.id
  AND affiliations.staff = staff.id
  AND affiliations.orgUnit = orgunits.id
  AND staff_roles.name = 'Dean'
  AND affiliations.role = staff_roles.id
  AND affiliations.ending IS NULL
  AND Orgunits.utype = 1
;



-- Q3: get details of the longest-serving and shortest-serving current Deans of Faculty
create or replace view Q3(status, name, faculty, starting)
as
--... SQL statements, possibly using other views/functions defined by you ...
(SELECT 'Shortest serving' as status, Q2.name, Q2.faculty, Q2.starting 
  FROM Q2
  WHERE starting = (SELECT MAX(starting) FROM Q2)
)
UNION
(SELECT 'Longest serving' as status, Q2.name, Q2.faculty, Q2.starting
  FROM Q2
  WHERE starting = (SELECT MIN(starting) from Q2)
)
;

-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
--... SQL statements, possibly using other views/functions defined by you ...
SELECT * FROM (
  SELECT CAST((CAST (uoc AS float)/NULLIF(CAST(eftsload AS float),0)) AS numeric(4,1)) AS ratio, count(*)
  FROM Subjects
  WHERE CAST(eftsload AS integer) IS NOT NULL
        OR CAST(uoc/eftsload AS numeric(4,1)) IS NOT NULL
  GROUP BY ratio
) AS results
WHERE ratio IS NOT NULL
;

