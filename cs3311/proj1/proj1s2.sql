-- COMP3311 17s1 Project 1
-- Mendel Liang z5019266
-- MyMyUNSW Solution Template


-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
SELECT Buildings.unswid, Buildings.name
FROM Buildings JOIN Rooms ON Buildings.id = Rooms.building
GROUP BY Buildings.unswid, Buildings.name
HAVING COUNT (Rooms.building) >= 30
;



-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
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
(SELECT 'Shortest serving' as status, Q2.name, Q2.faculty, Q2.starting 
FROM Q2
WHERE starting = (SELECT MAX(starting) FROM Q2))

UNION

(SELECT 'Longest serving' as status, Q2.name, Q2.faculty, Q2.starting
FROM Q2
WHERE starting = (SELECT MIN(starting) from Q2))
;




-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
SELECT * FROM (
  SELECT CAST((CAST (uoc AS float)/NULLIF(CAST(eftsload AS float),0)) AS numeric(4,1)) AS ratio, count(*)
  FROM Subjects
  WHERE CAST(eftsload AS integer) IS NOT NULL
        OR CAST(uoc/eftsload AS numeric(4,1)) IS NOT NULL
  GROUP BY ratio
) AS results
WHERE ratio IS NOT NULL 
;



-- Q5: program enrolments from 10s1
create or replace view Q5a(num)
as
SELECT COUNT(people.unswid)
FROM Program_enrolments, Streams, Stream_enrolments, Semesters, People, Students
WHERE Semesters.year = 2010
  AND Semesters.term = 'S1'
  AND Streams.code = 'SENGA1'
  AND Students.stype = 'intl'  
  AND People.id = Students.id
  AND Stream_enrolments.stream = Streams.id
  AND Stream_enrolments.partOf = Program_enrolments.id
  AND Program_enrolments.student = People.id
  AND Program_enrolments.semester = semesters.id
;

create or replace view Q5b(num)
as
SELECT COUNT(people.unswid)
FROM Program_enrolments, Semesters, People, Programs, Students
WHERE Semesters.year = 2010
  AND Semesters.term = 'S1'
  AND Students.stype = 'local'
  AND Programs.code = '3978'  
  AND People.id = Students.id
  AND Program_enrolments.program = Programs.id
  AND Program_enrolments.student = People.id
  AND Program_enrolments.semester = semesters.id
;

create or replace view Q5c(num)
as
SELECT COUNT(people.unswid)
FROM Programs, Program_enrolments, OrgUnits, Semesters, People
WHERE OrgUnits.name = 'Faculty of Engineering'
  AND Semesters.year = 2010
  AND Semesters.term = 'S1'
  AND Program_enrolments.program = Programs.id
  AND Program_enrolments.student = People.id
  AND Program_enrolments.semester = semesters.id
  AND Programs.offeredBy = OrgUnits.id
;



-- Q6: course CodeName
create or replace function
	Q6(text) returns text
as
$$
SELECT CONCAT(Subjects.code, ' ', Subjects.name)
FROM Subjects
WHERE Subjects.code = $1;

$$ language sql;


-- Q7: Percentage of growth of students enrolled in Database Systems
create or replace view Q7(year, term, perc_growth)
as
SELECT * FROM(
  SELECT Semesters.year, Semesters.term, 
  CAST((CAST(COUNT(course_enrolments) AS float)/(CAST(LAG(COUNT(course_enrolments)) OVER () AS float))) AS numeric(4,2)) AS perc_growth
  FROM Semesters, Subjects, Courses, Course_enrolments
  WHERE Subjects.name = 'Database Systems'
    AND course_enrolments.course = courses.id
    AND courses.subject = subjects.id
    AND semesters.id = courses.semester
  GROUP BY Semesters.year, Semesters.term, Semesters.starting
  ORDER BY Semesters.starting
) AS Q7
WHERE perc_growth IS NOT NULL
;

create or replace view Course_offerings(Subject)
as
SELECT id
FROM (
  SELECT Subjects.id, COUNT(Subjects.id) AS num
  FROM Subjects JOIN Courses ON Subjects.id = Courses.subject
  GROUP BY Subjects.id
  ORDER BY Subjects.Code
) AS Subject_Course_Count WHERE num>20
;


-- Q8: Least popular subjects
create or replace view Q8(subject)
as
SELECT CAST(CONCAT(Subjects.code, ' ', Subjects.name) as text)
FROM Subjects
WHERE Subjects.id IN(
  (SELECT Courses.subject 
   FROM Courses
   GROUP BY Courses.Subject
   HAVING COUNT(Courses.subject) >= 20)
  INTERSECT
  (
    (SELECT Courses.subject
     FROM Courses,
     (SELECT Course_enrolments.course, COUNT(Course_enrolments.course) as c
      FROM Course_enrolments
      WHERE Course_enrolments.course in
        (SELECT id
         FROM (SELECT Subject, id, row_number() OVER( PARTITION BY subject ORDER BY id DESC) AS rownum FROM courses) tmp WHERE rownum < 21)
         GROUP BY Course) as twenty WHERE Courses.id = twenty.Course GROUP BY Courses.subject HAVING COUNT(CASE WHEN C > 19 THEN 1 END) < 1)
     UNION
     ((SELECT Courses.subject FROM Courses) EXCEPT (SELECT Courses.subject FROM courses, Course_enrolments WHERE Courses.id = Course_enrolments.course))
  ) 
) ORDER BY Subjects.Code;
;




create or replace view Q9Passed(NumStudentsPassed, semester, year)
as
SELECT COUNT(Course_enrolments),  Semesters.term, Semesters.year
FROM Course_enrolments, Semesters, Subjects, Courses
WHERE Course_enrolments.mark >= 50
  AND Subjects.name = 'Database Systems'
  AND course_enrolments.course = courses.id
  AND courses.subject = subjects.id
  AND semesters.id = courses.semester
GROUP BY Semesters.term, Semesters.year
ORDER BY Semesters.year
;
create or replace view Q9Total(NumStudents, semester, year)
as
SELECT COUNT(Course_enrolments),  Semesters.term, Semesters.year
FROM Course_enrolments, Semesters, Subjects, Courses
WHERE Course_enrolments.mark >= 0
  AND Subjects.name = 'Database Systems'
  AND course_enrolments.course = courses.id
  AND courses.subject = subjects.id
  AND semesters.id = courses.semester
GROUP BY Semesters.term, Semesters.year
ORDER BY Semesters.year
;
create or replace view Q9Helper(year, s1_pass_rate, s2_pass_rate)
as
SELECT DISTINCT to_char(Q9Passed.year % 100, 'fm00'),
CAST(CAST((CASE WHEN Q9Passed.semester = 'S1' THEN NumStudentsPassed END) AS float) / CAST((CASE WHEN Q9Total.semester = 'S1' THEN NumStudents END) AS float ) AS numeric(4,2)),
CAST(CAST((CASE WHEN Q9Passed.semester = 'S2' THEN NumStudentsPassed END) AS float) / CAST((CASE WHEN Q9Total.semester = 'S2' THEN NumStudents END) AS float ) AS numeric(4,2))
FROM Q9Passed JOIN Q9Total ON Q9Passed.year = Q9Total.year
ORDER BY to_char(Q9Passed.year % 100, 'fm00')
;


-- Q9: Database Systems pass rate for both semester in each year
create or replace view Q9(year, s1_pass_rate, s2_pass_rate)
as
SELECT year,
CAST(MAX(s1_pass_rate) AS numeric(4,2)) AS s1_pass_rate,
CAST(MAX(s2_pass_rate) AS numeric(4,2)) AS s2_pass_rate
FROM Q9Helper
GROUP BY year
;

create or replace view Q10Courses(course)
as
SELECT Subjects.name, year,term, code
FROM Semesters JOIN Courses ON Courses.semester = Semesters.id
JOIN Subjects ON Courses.subject = subjects.id
WHERE code LIKE 'COMP93__'
  AND year <= 2013
  AND year >= 2002
  AND (term = 'S1'
  OR term = 'S2')
GROUP BY Subjects.name, Year, term, code
ORDER BY name, year
;

create or replace view Q10Courses2(code)
as
SELECT Q10Courses.code
FROM Q10Courses
GROUP BY Q10Courses.code
HAVING COUNT(*) = 24
;

create or replace view Q10Names(zid, name, subject)
as
SELECT CONCAT('z', People.unswid), People.name, Q10Courses2.code
FROM Course_enrolments JOIN Courses on (Course_enrolments.course = Courses.id)
  JOIN Subjects on (Subjects.id = Courses.subject)
  JOIN Semesters on (Semesters.id = Courses.semester)
  JOIN Q10Courses2 on (Q10Courses2.code = Subjects.code)
  JOIN Students on (Students.id = Course_enrolments.student)
  JOIN People on (People.id = Students.id)
WHERE Course_enrolments.mark < 50
  AND Course_enrolments.mark >= 0
GROUP BY People.id, People.name, Q10Courses2.code
ORDER BY Q10Courses2.code
;
-- Q10: find all students who failed all black series subjects

create or replace view Q10(zid, name)
as
SELECT Q10Names.zid, Q10Names.name
FROM Q10Names
GROUP BY Q10Names.name, Q10Names.zid
HAVING COUNT(*) = (SELECT COUNT(*) FROM Q10Courses2)
;
