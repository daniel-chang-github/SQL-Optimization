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

-- 3. List the names of students who have taken course v4 (crsCode).
EXPLAIN 
SELECT name FROM Student WHERE id IN (SELECT studId FROM Transcript WHERE crsCode = @v4);

-- '-> Inner hash join (student.id = `<subquery2>`.studId)  (cost=414.91 rows=400) (actual time=0.136..0.376 rows=2 loops=1)
--     -> Table scan on Student  (cost=5.04 rows=400) (actual time=0.005..0.223 rows=400 loops=1)
--     -> Hash
--         -> Table scan on <subquery2>  (cost=0.26..2.62 rows=10) (actual time=0.000..0.000 rows=2 loops=1)
--             -> Materialize with deduplication  (cost=11.51..13.88 rows=10) (actual time=0.105..0.105 rows=2 loops=1)
--                 -> Filter: (transcript.studId is not null)  (cost=10.25 rows=10) (actual time=0.048..0.100 rows=2 loops=1)
--                     -> Filter: (transcript.crsCode = <cache>((@v4)))  (cost=10.25 rows=10) (actual time=0.048..0.099 rows=2 loops=1)
--                         -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.023..0.083 rows=100 loops=1)



EXPLAIN ANALYZE
Select Student.name
from Student, Transcript
Where Student.id=Transcript.StudId AND Transcript.crsCode=@v4;

-- '-> Nested loop inner join  (cost=13.75 rows=10) (actual time=0.105..0.163 rows=2 loops=1)
--     -> Filter: ((transcript.crsCode = <cache>((@v4))) and (transcript.studId is not null))  (cost=10.25 rows=10) (actual time=0.050..0.103 rows=2 loops=1)
--         -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.023..0.086 rows=100 loops=1)
--     -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.26 rows=1) (actual time=0.028..0.029 rows=1 loops=2)
-- '

/*
Answer
CREATE INDEX idx_id on student (id);
CREATE INDEX idx_id on transcript (studId)

Created two indexes to reduce table scans. Table scan of 400 rows for Student table was reduced to 1 index lookup. I'm curious why the Transcript table is not using the index. It's still doing a table scan of 100 rows.

*/
