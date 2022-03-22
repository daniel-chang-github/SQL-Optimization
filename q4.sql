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

-- 4. List the names of students who have taken a course taught by professor v5 (name).

Explain 
SELECT name FROM Student,
	(SELECT studId FROM Transcript,
		(SELECT crsCode, semester FROM Professor
			JOIN Teaching
			WHERE Professor.name = @v5 AND Professor.id = Teaching.profId) as alias1
	WHERE Transcript.crsCode = alias1.crsCode AND Transcript.semester = alias1.semester) as alias2
WHERE Student.id = alias2.studId;

-- '-> Inner hash join (professor.id = teaching.profId)  (cost=1194.29 rows=4) (actual time=0.288..0.288 rows=0 loops=1)
--     -> Filter: (professor.`name` = <cache>((@v5)))  (cost=1.09 rows=4) (never executed)
--         -> Table scan on Professor  (cost=1.09 rows=400) (never executed)
--     -> Hash
--         -> Nested loop inner join  (cost=1045.70 rows=100) (actual time=0.283..0.283 rows=0 loops=1)
--             -> Filter: ((teaching.semester = transcript.semester) and (teaching.crsCode = transcript.crsCode))  (cost=1010.70 rows=100) (actual time=0.282..0.282 rows=0 loops=1)
--                 -> Inner hash join (<hash>(teaching.semester)=<hash>(transcript.semester)), (<hash>(teaching.crsCode)=<hash>(transcript.crsCode))  (cost=1010.70 rows=100) (actual time=0.282..0.282 rows=0 loops=1)
--                     -> Table scan on Teaching  (cost=0.01 rows=100) (actual time=0.007..0.067 rows=100 loops=1)
--                     -> Hash
--                         -> Filter: (transcript.studId is not null)  (cost=10.25 rows=100) (actual time=0.083..0.153 rows=100 loops=1)
--                             -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.082..0.146 rows=100 loops=1)
--             -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.25 rows=1) (never executed)
-- '

Explain analyze
SELECT 
	Student.name
FROM 
	Professor
INNER JOIN Teaching ON Professor.id = Teaching.profId
INNER JOIN Transcript on Teaching.crsCode = Transcript.crsCode 
INNER JOIN Student on Student.id= Transcript.studId
WHERE Professor.name = @v5 

-- -> Nested loop inner join  (cost=81.52 rows=10) (actual time=0.385..0.449 rows=2 loops=1)
--     -> Filter: (transcript.crsCode = teaching.crsCode)  (cost=55.52 rows=10) (actual time=0.365..0.424 rows=2 loops=1)
--         -> Inner hash join (<hash>(transcript.crsCode)=<hash>(teaching.crsCode))  (cost=55.52 rows=10) (actual time=0.364..0.423 rows=2 loops=1)
--             -> Filter: (transcript.studId is not null)  (cost=0.13 rows=10) (actual time=0.004..0.068 rows=100 loops=1)
--                 -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.004..0.062 rows=100 loops=1)
--             -> Hash
--                 -> Nested loop inner join  (cost=45.25 rows=10) (actual time=0.112..0.329 rows=1 loops=1)
--                     -> Filter: (teaching.profId is not null)  (cost=10.25 rows=100) (actual time=0.014..0.078 rows=100 loops=1)
--                         -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.014..0.070 rows=100 loops=1)
--                     -> Filter: (professor.`name` = <cache>((@v5)))  (cost=0.25 rows=0) (actual time=0.002..0.002 rows=0 loops=100)
--                         -> Index lookup on Professor using idx_id (id=teaching.profId)  (cost=0.25 rows=1) (actual time=0.002..0.002 rows=1 loops=100)
--     -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.25 rows=1) (actual time=0.011..0.012 rows=1 loops=2)


/*
Answer
CREATE INDEX idx_id on professor (id)
CREATE INDEX idx_id on student (id);

Created index on Student and Professor.
Used INNER JOINs instead of sub-queries.
Also, removed "Transcript.semester = alias1.semester" from line 21 as it results in incorrect answer.

*/
