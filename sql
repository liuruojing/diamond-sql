================================================================考查单个表的自联结操作
1、查询课程1分数比课程2分数高的学生信息以及课程成绩
select student.*,dto.score1,score2 from student INNER JOIN 
(SELECT
	a.SId,a.score score1,b.score score2
FROM
	sc a,
	sc b
WHERE
	a.SId = b.SId
AND a.CId = '01'
AND b.CId = '02'
AND a.score > b.score) dto
ON dto.SId=student.SId

1.1、查询同时选了" 01 "课程和" 02 "课程的学生信息以及课程成绩
select student.*,dto.score1,score2 from student INNER JOIN (
SELECT
	sc1.SId,sc1.score score1,sc2.score score2
FROM
	sc sc1,
	sc sc2
WHERE
	sc1.CId = '01'
AND sc2.CId = '02'
AND sc1.SId = sc2.SId)dto ON dto.SId=student.SId

1.2查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )

select * FROM
(select * from sc where sc.CId='01') as sc1
LEFT JOIN
(select * from sc where sc.CId='02') as sc2
ON sc1.SId=sc2.SId

1.3查询不存在" 01 "课程但存在" 02 "课程的情况
SELECT
	SId
FROM
	sc
WHERE
	CId = '02'
AND SId NOT IN (
	SELECT
		SId
	FROM
		sc
	WHERE
		CId = '01'
)
=====================================================================考查分组以及聚集函数的联合使用
2、查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select student.SId,student.Sname,dto.avg from student INNER JOIN(
SELECT
	SId,
	AVG(score) AS avg
FROM
	sc
GROUP BY
	SId
HAVING
	AVG(score) >= 60
)as dto
on dto.SId=student.SId

======================================================================考查distinct与IN语句
3、查询在 SC 表存在成绩的学生信息
select student.* from student where SId in(
select DISTINCT SId from sc
)
======================================================================考查计算字段与groupBy连用
4、查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
SELECT
	student.Sname,
	dto.*
FROM
	student
INNER JOIN (
	SELECT
		student.SId,
		COUNT(DISTINCT sc.CId),
		SUM(sc.score)
	FROM
		student
	LEFT JOIN sc ON sc.SId = student.SId
	GROUP BY
		student.SId
) AS dto ON dto.SId = student.SId

4.1查有成绩的学生信息
SELECT
	student.*
FROM
	student
WHERE
	student.SId IN (SELECT DISTINCT sc.SId FROM sc)

===================================================================考查模糊查询
5、查询「李」姓老师的数量
select count(*) from teacher where Tname like '李%'

====================================================================考查3个表以上的联结语句
6、查询学过「张三」老师授课的同学的信息
SELECT
	student.*
FROM
	student
INNER JOIN sc ON student.SId = sc.SId
AND sc.CId IN (
	SELECT
		course.CId
	FROM
		course
	INNER JOIN teacher ON course.TId = teacher.TId
	AND teacher.Tname = '张三'
)

select student.* from student,teacher,course,sc
where 
teacher.Tname ='张三' AND
course.TId = teacher.TId AND
sc.CId=course.CId AND
student.SId=sc.SId

7、查询没有学全所有课程的同学的信息
SELECT
	*
FROM
	student
WHERE
	SId IN (
		SELECT
			SId
		FROM
			sc
		GROUP BY
			SId
		HAVING
			COUNT(*) < (SELECT count(*) FROM course)
	)

8、查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
SELECT
	student.*
FROM
	student
WHERE
	student.SId IN (
		SELECT DISTINCT
			sc.SId
		FROM
			sc
		WHERE
			sc.CId IN (
				SELECT
					sc.CId
				FROM
					sc
				WHERE
					sc.SId = '01'
			)
		AND SId != '01'
	)
============================================================考查先where筛选行，group by分组，having再筛选分组
9、查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
SELECT
	student.*
FROM
	student
WHERE
	student.SId IN (
		SELECT 
			sc.SId
		FROM
			sc
		WHERE
			sc.CId IN (
				SELECT
					sc.CId
				FROM
					sc
				WHERE
					sc.SId = '01'
			)
		AND SId != '01'
GROUP BY sc.SId
HAVING COUNT(*)=(SELECT
					count(*)
				FROM
					sc
				WHERE
					sc.SId = '01')
	)
#查询没学过"张三"老师讲授的任一门课程的学生姓名
select * from student where student.SId NOT IN(
#查询出选过这些课的学生
select SId from sc where sc.CId IN(
#查询出张三老师讲过的课
select course.CId from course INNER JOIN teacher ON Tname='张三' AND course.TId=teacher.TId
))
==============================================考查先where筛选行，group by分组，having再筛选分组，最后两表联结
10、查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
select student.* from student RIGHT JOIN (
select SId,AVG(score) from sc 
where score<60
GROUP BY SId
HAVING count(*)>=2
)dto ON student.SId=dto.SId
====================================================考察order by以及子查询
11、检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select student.*,dto.score from  student INNER JOIN 
(select * from sc where CId='01' and score<60)dto
on student.SId=dto.SId
ORDER BY score DESC
