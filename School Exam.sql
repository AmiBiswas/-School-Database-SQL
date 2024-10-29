create database Accenture;
use  Accenture;
select * from exam_paper;
select * from exam;
select * from student;
select * from class;
select * from Class_Curriculum;
select * from teacher;
select * from teacher_allocation;

/*1) In the school one teacher might be teaching more than one class. Write a query to identify how many classes cach teacher is taking*/
Select teacher_id, Count(*) from teacher_allocation group by teacher_id;

/*2)It is interesting for teachers to come across students with names similar to theirs. Join is one of the teachers who finds this fascinating 
and wants to find out how many students in each class have names similar to his. Write a query to help him find this data */
 select class_id, count(student_name) as no_of_johns
from student
where student_name like "%John%" 
group by class_id;

/*3) Every class teacher assigns unique roll number to their class students based on the alphabetical order of their names.
 Can you help by writing a query that will assign roll number to each student in a class*/
select student_name ,class_id,
ROW_NUMBER () OVER ( PARTITION BY class_id order by class_id desc) from student;


SELECT student_Name, class_id
, (SELECT Count(*) from Student as s2 
where s1.student_Name > s2.student_Name and s1.class_id = s2.class_id)+1 as UniqueRollNo
FROM Student as S1 
Order By 3;

/*4) The principal of the school wants to understand the diversity of students in his school. One of the
important aspects is gender diversity. Provide a query that computes the male to female gender rate in inench class */
select class_id,ifnull(gender,'subtotal') as 'index', count(gender) from student
group by class_id,gender with rollup
order by class_id desc;

/*5) Every school has teachers with different years of experience working in that school.
 The principal wants to know the average experience of teachers at this school (2 Marks)*/
SELECT teacher_id, TIMESTAMPDIFF(YEAR, date_of_joining, CURDATE()) AS experience 
FROM teacher 
GROUP BY teacher_id ,experience;

/*6) At the end of every year class teachers must provide students with their marks sheet for the whole year The marks sheet of a student
 consists of exam (Quarterly, Half-yearly, etc.)wise marks obtained out of the total marks. Help them by writing a query that gives the student wise marks sheet (3 Marks)*/
select s.student_id,student_name,exam_name,total_marks,marks from exam as e
join exam_paper as ep on e.exam_id=ep.exam_id join student as s on s.student_id=ep.student_id
group by s.student_id,student_name,exam_name,ep.marks,total_marks
order by s.student_id ;

select student_name,exam_name,total_marks,marks,s.student_id from exam as e
join exam_paper as ep on e.exam_id=ep.exam_id join student as s on s.student_id=ep.student_id
group by student_name, exam_name, total_marks, marks, s.student_id
order by 1 ;


/*7) Every teacher has certain group of favourite students and keep track of their performance in exams. 
A teacher approached you to find out the percentages attained by students with ids 1,4,9,16,25 in the "Quarterly" exam. Write a query to obtain this data for each student*/
select s.student_id,student_name,exam_name,(marks/total_marks)*100 as percentage from exam as e
join exam_paper as ep on ep.exam_id=e.exam_id join student as s  on  s.student_id=ep.student_id
where s.student_id in (1,4,9,16,25) and exam_name="Quarterly" ;



SELECT student_name, concat(round((SUM(marks) / sum(total_marks))* 100,0),"%")  AS percentage 
FROM exam AS e
JOIN exam_paper AS ep ON ep.exam_id = e.exam_id 
JOIN student AS s ON s.student_id = ep.student_id 
WHERE s.student_id IN (1, 4, 9, 16, 25) AND exam_name = "Quarterly" 
GROUP BY student_name;

/*8) Class teachers assign ranks to their students based on their marks obtained in each exam. 
Write a query to assign ranks (continuous) to students in each class for "Half-yearly" exams (3 Marks)*/
SELECT student_id, class_standard, marks,
       DENSE_RANK() OVER (PARTITION BY class_standard ORDER BY marks DESC) AS myRank
FROM exam_paper AS ep
JOIN exam AS e ON ep.exam_id = e.exam_id 
WHERE exam_name = 'half yearly';

WITH StudentTotal AS (
    SELECT student_id, class_standard,
           SUM(marks) AS TotalMarks,
           COUNT(*) AS ExamCount
    FROM exam_paper AS ep
    JOIN exam AS e ON ep.exam_id = e.exam_id
    WHERE exam_name = 'half yearly'
    GROUP BY student_id, class_standard
)
SELECT student_id, class_standard, TotalMarks, ExamCount,
       DENSE_RANK() OVER (PARTITION BY class_standard ORDER BY TotalMarks DESC) AS 'Rank'
FROM StudentTotal
ORDER BY class_standard, 'Rank';