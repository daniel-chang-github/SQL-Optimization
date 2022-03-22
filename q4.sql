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
SELECT name FROM Student,
	(SELECT studId FROM Transcript,
		(SELECT crsCode, semester FROM Professor
			JOIN Teaching
			WHERE Professor.name = @v5 AND Professor.id = Teaching.profId) as alias1
	WHERE Transcript.crsCode = alias1.crsCode AND Transcript.semester = alias1.semester) as alias2
WHERE Student.id = alias2.studId;

Explain 
SELECT name FROM Student,
	(SELECT studId FROM Transcript,
		(SELECT crsCode, semester FROM Professor
			JOIN Teaching
			WHERE Professor.name = @v5 AND Professor.id = Teaching.profId) as alias1
	WHERE Transcript.crsCode = alias1.crsCode AND Transcript.semester = alias1.semester) as alias2
WHERE Student.id = alias2.studId

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

-- Created index on Student (400 rows scan to 1 lookup) and Professor 