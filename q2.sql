USE springboardopt;

-- -------------------------------------
SET @v1 = 1612521;
SET @v2 = 1145072;
SET @v3 = 1828467;
SET @v4 = 'MGT382';
SET @v5 = 'Amber Hill';
SET @v6 = 'MGT';
SET @v7 = 'EE';			  
SET @v8 = 'MAT';

-- 2. List the names of students with id in the range of v2 (id) to v3 (inclusive).
EXPLAIN analyze
SELECT name FROM Student WHERE id BETWEEN @v2 AND @v3;

-- '-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=41.00 rows=278) (actual time=0.025..0.277 rows=278 loops=1)
--     -> Table scan on Student  (cost=41.00 rows=400) (actual time=0.022..0.238 rows=400 loops=1)
-- '

-- Optimization not necessary? Index is not being used. Is it becuase the query is searching for a range?