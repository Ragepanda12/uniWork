-- COMP3311 17s1 Project 2
--
-- Section 1 Template

--Q1: ...
create type IncorrectRecord as (pattern_number integer, uoc_number integer);

create or replace function Q1(pattern text, uoc_threshold integer) 
	returns IncorrectRecord
as $$
Declare incorrect IncorrectRecord;
begin
	select count(distinct code) into incorrect.pattern_number from subjects where code LIKE $1 and eftsload != cast(uoc AS float)/48;
	select count(distinct code) into incorrect.uoc_number from subjects where eftsload != cast(uoc AS float)/48 and code LIKE $1 and uoc > $2;
	return incorrect;
--... SQL statements, possibly using other views/functions defined by you ...
end;
$$ language plpgsql;


create or replace function semCode(year CourseYearType, sem char(2))
	returns char(4)
as $$
SELECT CONCAT(to_char(year % 100, 'fm00'), sem);

$$ language sql;

-- Q2: ...
create type TranscriptRecord as (cid integer, term char(4), code char(8), name text, uoc integer, mark integer, grade char(2), rank integer, totalEnrols integer);

create or replace function Q2(stu_unswid integer)
	returns setof TranscriptRecord
as $$
Declare transcript TranscriptRecord;
Declare element integer;
begin
	FOR element in	
		select c.id from courses c join course_enrolments ce on c.id = ce.course, people
		where people.unswid = $1 and people.id = ce.student
	LOOP
		select element into transcript.cid;
		select CONCAT(to_char(s.year % 100, 'fm00'), lower(s.term)) into transcript.term from semesters s join courses c on s.id = c.semester 
			where c.id = element;
		select s.code into transcript.code from Subjects s join Courses c on s.id = c.subject
			where element = c.id;
		select s.name into transcript.name from Subjects s join Courses c on s.id = c.subject
			where element = c.id;
		select CASE WHEN ce.grade = 'SY' THEN s.uoc 
			WHEN ce.grade = 'RS' THEN s.uoc
			WHEN ce.grade = 'PT' THEN s.uoc
			WHEN ce.grade = 'PC' THEN s.uoc
			WHEN ce.grade = 'PS' THEN s.uoc
			WHEN ce.grade = 'CR' THEN s.uoc
			WHEN ce.grade = 'DN' THEN s.uoc
			WHEN ce.grade = 'HD' THEN s.uoc
			WHEN ce.grade = 'A' THEN s.uoc
			WHEN ce.grade = 'B' THEN s.uoc
			WHEN ce.grade = 'C' THEN s.uoc
			WHEN ce.grade = 'D' THEN s.uoc
			WHEN ce.grade = 'E' THEN s.uoc
			ELSE 0 
		END into transcript.uoc from Subjects s join Courses c on s.id = c.subject, course_enrolments ce
			where element = c.id
			and ce.course = element;
		select ce.mark into transcript.mark from course_enrolments ce, people p 
			where ce.course = element
			and p.unswid = $1 and p.id = ce.student;
		select ce.grade into transcript.grade from course_enrolments ce, people p
			where ce.course = element
			and p.unswid = $1 and p.id = ce.student;
		select CASE WHEN (SELECT DISTINCT COUNT(*) FROM course_enrolments ce where ce.mark is not null 
			and ce.course = element) = 0 THEN null
		 	ELSE rankinfo.rank 
		 	END
			into transcript.rank from 
			(select *, rank() over (PARTITION BY course ORDER BY ce.mark desc) from course_enrolments ce where ce.course = element) as rankinfo, people p 
			where p.unswid = $1 and p.id = rankinfo.student;
		select count(*) from course_enrolments ce into transcript.totalEnrols
		where ce.mark is not null
		and ce.course = element;
		return next transcript;
	END LOOP;
	RETURN; 
end;
--... SQL statements, possibly using other views/functions defined by you ...
$$ language plpgsql;

create or replace function distinct_sub(org_id integer, id integer) returns integer 
as $$
	declare num integer;
	begin
	select count(distinct subjects.code) into num from staff
		join course_staff on course_staff.staff = staff.id
		join courses on courses.id = course_staff.course
		join subjects on subjects.id = courses.subject
		join affiliations on affiliations.staff = staff.id
		join orgunits on orgunits.id = affiliations.orgunit
		join orgunit_groups on orgunit_groups.member = orgunits.id
		where staff.id = $2 and orgunit_groups.owner = $1 and course_staff.role != (select staff_roles.id from staff_roles where name = 'Course Tutor');
		return num;
	end
$$ language plpgsql;

create or replace function num_times(subjectid integer, id integer) returns integer 
as $$
	declare num integer;
	begin
	select count(courses.id) into num from staff
		join course_staff on course_staff.staff = staff.id
		join courses on courses.id = course_staff.course
		join subjects on subjects.id = courses.subject
		where staff.id = $2 and subjects.id = $1
		and course_staff.role != (select staff_roles.id from staff_roles where name = 'Course Tutor');
		return num;
	end
$$ language plpgsql;

create type TeachingRecord as (unswid integer, staff_name text, teaching_records text);

create or replace function Q3(org_id integer, num_sub integer, num_times integer) 
    returns setof TeachingRecord
as $$ 
declare record TeachingRecord; 
declare person integer; 
declare subject integer;
begin
    for person in 
		select distinct people.id from people
			join staff on staff.id = people.id
			join affiliations on affiliations.staff = staff.id
			join orgunits on orgunits.id = affiliations.orgUnit
			join orgunit_groups on orgunit_groups.member = orgunits.id
			where orgunit_groups.owner = $1
			and distinct_sub(orgunit_groups.owner, staff.id) > $2
    loop
		record.teaching_records = null;
		for subject in
			select distinct subjects.id from subjects  
				join courses on courses.subject = subjects.id
				join course_staff on course_staff.course = courses.id
				join staff on staff.id = course_staff.staff
				where staff.id = person and (select * from num_times(subjects.id, person)) > 8		
		loop 
			if record.teaching_records is null then
			record.teaching_records = '';
			end if;
			select record.teaching_records || subjects.code || ', ' || orgunits.name || chr(10) into record.teaching_records
				from subjects
				join orgunits on orgunits.id = subjects.offeredby
				where subjects.id = subject;
		end loop;
			if record.teaching_records is not null then
				select people.unswid, people.name into record.unswid, record.staff_name
					from people
					where people.id = person;
				return next record; 
			end if;
    end loop; 
	return; 
end; 
$$ language plpgsql;






 



