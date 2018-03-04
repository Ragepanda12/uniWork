-- COMP3311 17s1 Project 2
--
-- Section 2 Template

--------------------------------------------------------------------------------
-- Q4
--------------------------------------------------------------------------------

drop function if exists skyline_naive(text) cascade;

-- This function calculates skyline in O(n^2)
create or replace function skyline_naive(dataset text) 
    returns integer 
as $$
	declare c integer;
	begin
		EXECUTE (
			'create or replace view ' || dataset ||'_skyline_naive_dominated(a,b) as ' ||
			'select distinct on (s1.x, s1.y) s1.x, s1.y from ' || dataset || ' as s1 cross join ' || dataset || ' as s2 ' ||
			'where (s2.x >= s1.x and s2.y > s1.y) or (s2.x > s1.x and s2.y >= s1.y)' 
		);
		EXECUTE (
			'create or replace view ' || dataset ||'_skyline_naive(x,y) as ' ||
			'select x, y from ' || dataset || 
			' where (x,y) not in (select a, b from ' || dataset ||'_skyline_naive_dominated)'
		);
		EXECUTE 'SELECT count(*) from ' || dataset || '_skyline_naive' into c;
	return c;
	end;
$$ language plpgsql;

--------------------------------------------------------------------------------
-- Q5
--------------------------------------------------------------------------------

drop function if exists skyline(text) cascade;

-- This function simply creates a view to store skyline
create or replace function skyline(dataset text) 
    returns integer 
as $$
	declare c integer;
	begin
		EXECUTE (
			'create or replace view ' || dataset ||'_skyline_descending_y(a,b) as ' ||
			'select x, y from ' || dataset || 
			' order by y DESC, x DESC'
		);
		EXECUTE (
			'create or replace view ' || dataset ||'_skyline(x,y) as ' ||
			'select a as x, b as y from (select distinct on (b) a, b, max(a) OVER (order by b desc rows between unbounded preceding and 1 preceding) as prev from ' || dataset || '_skyline_descending_y order by b desc) as distincts ' ||
			'where a > prev or prev is null ' ||
			'order by y desc'
		);
		EXECUTE 'SELECT count(*) from ' || dataset || '_skyline' into c;
	return c;
	end;
$$ language plpgsql;

--------------------------------------------------------------------------------
-- Q6
--------------------------------------------------------------------------------

drop function if exists skyband_naive(text) cascade;

-- This function calculates skyband in O(n^2)
create or replace function skyband_naive(dataset text, k integer) 
    returns integer 
as $$
	declare c integer;
	begin
		EXECUTE (
			'create or replace view ' || dataset ||'_skyband_naive(x,y) as ' ||
			'select x, y from ' ||
			'((select s1.x, s1.y from ' || dataset || ' as s1 cross join ' || dataset || ' as s2 ' ||
			'where (s2.x >= s1.x and s2.y > s1.y) or (s2.x > s1.x and s2.y >= s1.y)) ' ||
			' UNION ALL' ||
			'(select x, y from ' || dataset || ')) as hi group by hi.x, hi.y having count(*) <= ' || k 
		);
		EXECUTE 'SELECT count(*) from ' || dataset || '_skyband_naive' into c;
	return c;
	end;
$$ language plpgsql;

--------------------------------------------------------------------------------
-- Q7
--------------------------------------------------------------------------------

drop function if exists skyband(text, integer) cascade;

-- This function simply creates a view to store skyband
create or replace function skyband(dataset text, k integer) 
    returns integer 
as $$
	declare c integer;
	declare iteration integer;
begin
	FOR iteration in 1..k
	LOOP
		IF iteration = 1 THEN
		EXECUTE (
			'create or replace view ' || dataset ||'_skyband_descending_'||iteration||'(a,b) as ' ||
			'select x, y from ' || dataset || 
			' order by y DESC, x DESC'
		);
		EXECUTE (
			'create or replace view ' || dataset ||'_skyband_'||iteration||'(x,y) as ' ||
			'select a as x, b as y from (select distinct on (b) a, b, max(a) OVER (order by b desc rows between unbounded preceding and 1 preceding) as prev from ' || dataset || '_skyband_descending_'||iteration||' order by b desc) as distincts ' ||
			'where a > prev or prev is null ' ||
			'order by y desc'
		);
		ELSE
		EXECUTE (
			'create or replace view ' || dataset ||'_skyband_descending_'||iteration||'(a,b) as ' ||
			'select a, b from ' || dataset || '_skyband_descending_' || iteration - 1 || ' as hi' ||
			' where (a,b) not in (select x, y from ' || dataset || '_skyband_' || iteration - 1 || 
			') order by b DESC, a DESC'
		);
		EXECUTE (
			'create or replace view ' || dataset ||'_skyband_'||iteration||'(x,y) as ' ||
			'(select a as x, b as y from (select distinct on (b) a, b, max(a) OVER (order by b desc rows between unbounded preceding and 1 preceding) as prev from ' || dataset || '_skyband_descending_'||iteration||' order by b desc) as distincts ' ||
			'where a > prev or prev is null ' ||
			'order by y desc) UNION (select * from ' || dataset || '_skyband_' || iteration-1 || ')'
		);
		END IF;

	END LOOP;
	EXECUTE 'select * from skyband_naive(''' || dataset || '_skyband_' || k || ''', ' || k || ')';
	EXECUTE 'create or replace view ' || dataset || '_skyband(x,y) as ' ||
			'select * from '|| dataset || '_skyband_' || k || '_skyband_naive';
	EXECUTE 'SELECT count(*) from ' || dataset || '_skyband' into c;
	return c;
end;

$$ language plpgsql;	