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
========================================================考察计算字段子查询与GROUP_CONCAT函数
12、按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select student.SId,student.Sname,
(select GROUP_CONCAT(score) as score from sc where sc.SId=student.SId) as score,
(select AVG(score) as score from sc where sc.SId=student.SId) as avg_score  
from student 
13、 查询各科成绩最高分、最低分和平均分：
以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列

14、按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺 
不会

=====================================================================考查sql中变量的使用
15、查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
set @rank=0;
select dto.*,@rank:=@rank+1 as rank from
(select sc.SId,SUM(score) from sc GROUP BY sc.SId
ORDER BY SUM(score) DESC )dto

==========================================================================================考查计算字段为子查询
16、统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select course.CId,course.Cname,
(select count(*) from sc where sc.CId = course.CId and sc.score >85 and sc.score<=100)/(select count(*) from sc where sc.CId = course.CId) as '[85-100]',
(select count(*) from sc where sc.CId = course.CId and sc.score >70 and sc.score<=85)/(select count(*) from sc where sc.CId = course.CId) as '[70-85]',
(select count(*) from sc where sc.CId = course.CId and sc.score >60 and sc.score<=70)/(select count(*) from sc where sc.CId = course.CId) as '[60-70]',
(select count(*) from sc where sc.CId = course.CId and sc.score >=0 and sc.score<=60)/(select count(*) from sc where sc.CId = course.CId) as '[0-60]'
 from course
 17、查询各科成绩前三名的记录 
 不会
