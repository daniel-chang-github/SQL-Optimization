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

-- 6. List the names of students who have taken all courses offered by department v8 (deptId).

EXPLAIN analyze
SELECT name FROM Student,
	(SELECT studId
	FROM Transcript
		WHERE crsCode IN
		(SELECT crsCode FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))
		GROUP BY studId
		HAVING COUNT(*) = 
			(SELECT COUNT(*) FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))) as alias
WHERE id = alias.studId;

-- '-> Nested loop inner join  (cost=48.75 rows=100) (actual time=4.068..4.068 rows=0 loops=1)
--     -> Filter: (alias.studId is not null)  (cost=0.14..13.75 rows=100) (actual time=4.067..4.067 rows=0 loops=1)
--         -> Table scan on alias  (cost=2.50..2.50 rows=0) (actual time=0.000..0.000 rows=0 loops=1)
--             -> Materialize  (cost=2.50..2.50 rows=0) (actual time=4.067..4.067 rows=0 loops=1)
--                 -> Filter: (count(0) = (select #5))  (actual time=4.062..4.062 rows=0 loops=1)
--                     -> Table scan on <temporary>  (actual time=0.000..0.001 rows=19 loops=1)
--                         -> Aggregate using temporary table  (actual time=4.058..4.060 rows=19 loops=1)
--                             -> Nested loop inner join  (cost=1020.25 rows=10000) (actual time=0.229..0.365 rows=19 loops=1)
--                                 -> Filter: (transcript.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.033..0.112 rows=100 loops=1)
--                                     -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.032..0.104 rows=100 loops=1)
--                                 -> Single-row index lookup on <subquery3> using <auto_distinct_key> (crsCode=transcript.crsCode)  (actual time=0.000..0.000 rows=0 loops=100)
--                                     -> Materialize with deduplication  (cost=120.52..120.52 rows=100) (actual time=0.239..0.241 rows=19 loops=1)
--                                         -> Filter: (course.crsCode is not null)  (cost=110.52 rows=100) (actual time=0.104..0.179 rows=19 loops=1)
--                                             -> Filter: (teaching.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.103..0.178 rows=19 loops=1)
--                                                 -> Inner hash join (<hash>(teaching.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.103..0.174 rows=19 loops=1)
--                                                     -> Table scan on Teaching  (cost=0.13 rows=100) (actual time=0.003..0.058 rows=100 loops=1)
--                                                     -> Hash
--                                                         -> Filter: (course.deptId = <cache>((@v8)))  (cost=10.25 rows=10) (actual time=0.014..0.082 rows=19 loops=1)
--                                                             -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.005..0.066 rows=100 loops=1)
--                     -> Select #5 (subquery in condition; uncacheable)
--                         -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.189..0.189 rows=1 loops=19)
--                             -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.103..0.188 rows=19 loops=19)
--                                 -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.003..0.073 rows=19 loops=19)
--                                     -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.002..0.059 rows=100 loops=19)
--                                 -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
--                                     -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.109..0.111 rows=97 loops=19)
--                                         -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.002..0.066 rows=100 loops=19)
--                                             -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.058 rows=100 loops=19)
--                 -> Select #5 (subquery in projection; uncacheable)
--                     -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.189..0.189 rows=1 loops=19)
--                         -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.103..0.188 rows=19 loops=19)
--                             -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.003..0.073 rows=19 loops=19)
--                                 -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.002..0.059 rows=100 loops=19)
--                             -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
--                                 -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.109..0.111 rows=97 loops=19)
--                                     -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.002..0.066 rows=100 loops=19)
--                                         -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.058 rows=100 loops=19)
--     -> Index lookup on Student using idx_id (id=alias.studId)  (cost=0.25 rows=1) (never executed)
-- '



EXPLAIN ANALYZE
SELECT * FROM Student, Transcript, Course, Teaching
WHERE Student.id = Transcript.studId
AND Course.crsCode = Transcript.crsCode
AND Teaching.crsCode = Course.crsCode
AND deptId = @v8 
GROUP BY id

HAVING count(*) > (
SELECT count(*) from Teaching, Course
WHERE Teaching.crsCode = Course.crsCode
And deptId='MAT'
)

-- '-> Filter: (count(0) > (select #2))  (actual time=0.652..0.652 rows=0 loops=1)
--     -> Table scan on <temporary>  (actual time=0.001..0.003 rows=19 loops=1)
--         -> Aggregate using temporary table  (actual time=0.410..0.414 rows=19 loops=1)
--             -> Filter: (teaching.crsCode = course.crsCode)  (cost=147.66 rows=100) (actual time=0.273..0.355 rows=19 loops=1)
--                 -> Inner hash join (<hash>(teaching.crsCode)=<hash>(course.crsCode))  (cost=147.66 rows=100) (actual time=0.273..0.352 rows=19 loops=1)
--                     -> Table scan on Teaching  (cost=0.02 rows=100) (actual time=0.003..0.064 rows=100 loops=1)
--                     -> Hash
--                         -> Nested loop inner join  (cost=46.53 rows=10) (actual time=0.125..0.257 rows=19 loops=1)
--                             -> Filter: (transcript.crsCode = course.crsCode)  (cost=20.53 rows=10) (actual time=0.113..0.199 rows=19 loops=1)
--                                 -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=20.53 rows=10) (actual time=0.113..0.196 rows=19 loops=1)
--                                     -> Filter: (transcript.studId is not null)  (cost=0.13 rows=10) (actual time=0.004..0.071 rows=100 loops=1)
--                                         -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.004..0.064 rows=100 loops=1)
--                                     -> Hash
--                                         -> Filter: (course.deptId = <cache>((@v8)))  (cost=10.25 rows=10) (actual time=0.022..0.092 rows=19 loops=1)
--                                             -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.015..0.076 rows=100 loops=1)
--                             -> Index lookup on Student using idx_id (id=transcript.studId)  (cost=0.25 rows=1) (actual time=0.002..0.003 rows=1 loops=19)
--     -> Select #2 (subquery in condition; run only once)
--         -> Aggregate: count(0)  (cost=120.52 rows=100) (actual time=0.193..0.193 rows=1 loops=1)
--             -> Filter: (teaching.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.119..0.191 rows=19 loops=1)
--                 -> Inner hash join (<hash>(teaching.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.118..0.187 rows=19 loops=1)
--                     -> Table scan on Teaching  (cost=0.13 rows=100) (actual time=0.002..0.056 rows=100 loops=1)
--                     -> Hash
--                         -> Filter: (course.deptId = ''MAT'')  (cost=10.25 rows=10) (actual time=0.004..0.107 rows=19 loops=1)
--                             -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.003..0.095 rows=100 loops=1)
-- '


-- Reduced costs by using less SELECT statements. Also, I added "AND deptId = @v8 " at row 73 to filter the transactions before aggregating using GROUP BY.