-- COMP3311 17s1 Project 1
--
-- MyMyUNSW Solution Template


-- Q1: buildings that have more than 30 rooms
create or replace view Q1(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q2: get details of the current Deans of Faculty
create or replace view Q2(name, faculty, phone, starting)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q3: get details of the longest-serving and shortest-serving current Deans of Faculty
create or replace view Q3(status, name, faculty, starting)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q4 UOC/ETFS ratio
create or replace view Q4(ratio,nsubjects)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q5: program enrolments from 10s1
create or replace view Q5a(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

create or replace view Q5b(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

create or replace view Q5c(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q6: course CodeName
create or replace function
	Q6(text) returns text
as
$$
--... SQL statements, possibly using other views/functions defined by you ...
$$ language sql;



-- Q7: Percentage of growth of students enrolled in Database Systems
create or replace view Q7(year, term, perc_growth)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q8: Least popular subjects
create or replace view Q8(subject)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q9: Database Systems pass rate for both semester in each year
create or replace view Q9(year, s1_pass_rate, s2_pass_rate)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



-- Q10: find all students who failed all black series subjects
create or replace view Q10(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;



