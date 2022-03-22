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

-- 5. List the names of students who have taken a course from department v6 (deptId), but not v7.

EXPLAIN ANALYZE 
SELECT * FROM Student, 
	(SELECT studId FROM Transcript, Course WHERE deptId = @v6 AND Course.crsCode = Transcript.crsCode
	AND studId NOT IN
	(SELECT studId FROM Transcript, Course WHERE deptId = @v7 AND Course.crsCode = Transcript.crsCode)) as alias
WHERE Student.id = alias.studId;

-- '-> Nested loop inner join  (cost=46.52 rows=10) (actual time=0.949..3.486 rows=30 loops=1)
--     -> Filter: (transcript.crsCode = course.crsCode)  (cost=20.52 rows=10) (actual time=0.781..0.871 rows=30 loops=1)
--         -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=20.52 rows=10) (actual time=0.780..0.865 rows=30 loops=1)
--             -> Filter: (transcript.studId is not null)  (cost=0.13 rows=10) (actual time=0.005..0.071 rows=100 loops=1)
--                 -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.004..0.063 rows=100 loops=1)
--             -> Hash
--                 -> Filter: (course.deptId = <cache>((@v6)))  (cost=10.25 rows=10) (actual time=0.684..0.756 rows=26 loops=1)
--                     -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.677..0.738 rows=100 loops=1)
--     -> Filter: <in_optimizer>(transcript.studId,<exists>(select #3) is false)  (cost=0.25 rows=1) (actual time=0.086..0.087 rows=1 loops=30)
--         -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.25 rows=1) (actual time=0.003..0.004 rows=1 loops=30)
--         -> Select #3 (subquery in condition; dependent)
--             -> Limit: 1 row(s)  (cost=10.22 rows=0) (actual time=0.081..0.081 rows=0 loops=30)
--                 -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(transcript.studId), true)  (cost=10.22 rows=0) (actual time=0.081..0.081 rows=0 loops=30)
--                     -> Filter: (course.crsCode = transcript.crsCode)  (cost=10.22 rows=0) (actual time=0.080..0.080 rows=0 loops=30)
--                         -> Inner hash join (<hash>(course.crsCode)=<hash>(transcript.crsCode))  (cost=10.22 rows=0) (actual time=0.080..0.080 rows=0 loops=30)
--                             -> Filter: (course.deptId = <cache>((@v7)))  (cost=4.71 rows=1) (actual time=0.004..0.070 rows=32 loops=30)
--                                 -> Table scan on Course  (cost=4.71 rows=100) (actual time=0.001..0.058 rows=100 loops=30)
--                             -> Hash
--                                 -> Filter: <if>(outer_field_is_not_null, ((<cache>(transcript.studId) = transcript.studId) or (transcript.studId is null)), true)  (cost=0.70 rows=2) (actual time=0.003..0.004 rows=1 loops=30)
--                                     -> Alternative plans for IN subquery: Index lookup unless studId IS NULL  (cost=0.70 rows=2) (actual time=0.003..0.004 rows=1 loops=30)
--                                         -> Index lookup on Transcript using idx_id (studId=<cache>(transcript.studId) or NULL)  (actual time=0.002..0.004 rows=1 loops=30)
--                                         -> Table scan on Transcript  (never executed)
-- '


EXPLAIN  
SELECT * FROM Student, Transcript, Course
WHERE Student.id = Transcript.studId
AND Course.crsCode = Transcript.crsCode
AND deptId = @v6 
AND deptId != @v7

-- -> Nested loop inner join  (cost=46.53 rows=10) (actual time=0.125..0.298 rows=30 loops=1)
--     -> Filter: (transcript.crsCode = course.crsCode)  (cost=20.53 rows=10) (actual time=0.112..0.208 rows=30 loops=1)
--         -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=20.53 rows=10) (actual time=0.111..0.202 rows=30 loops=1)
--             -> Filter: (transcript.studId is not null)  (cost=0.13 rows=10) (actual time=0.004..0.077 rows=100 loops=1)
--                 -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.004..0.066 rows=100 loops=1)
--             -> Hash
--                 -> Filter: (course.deptId = <cache>((@v6)))  (cost=10.25 rows=10) (actual time=0.016..0.090 rows=26 loops=1)
--                     -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.014..0.076 rows=100 loops=1)
--     -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.25 rows=1) (actual time=0.002..0.003 rows=1 loops=30)


-- Curious why index in Transcript table was not used in q3 and q4 but it's beig used in q5.
-- Index on Student table and inner joins instead of subqueries elimiated line 30 to 43. Line 22 and line 29 are the same.