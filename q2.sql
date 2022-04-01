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


/*
Answer
Crated an index on the Student table. However, the index is not being used. Is it becuase the query is searching for a range?

After the Skype call. Created a composit index and reduced 400 table scans to 278 index range scans. Bud the cost went up from 41 to 64.52??

*/
CREATE INDEX student_indx ON Student(id,name) 

EXPLAIN analyze
SELECT name FROM Student WHERE id BETWEEN @v2 AND @v3;

-- '-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=64.52 rows=278) (actual time=0.021..0.233 rows=278 loops=1)
--     -> Covering index range scan on Student using student_indx  (cost=64.52 rows=278) (actual time=0.018..0.202 rows=278 loops=1)
-- '
