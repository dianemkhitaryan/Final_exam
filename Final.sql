-- 1. get number of students
select count(1) as number_of_students from students s 

-- 2. get student population in each year
select count(1) as student_population, s.student_population_year_ref from students s 
group by s.student_population_year_ref 

-- 3. get population in each program
select count(1) as student_population, s.student_population_code_ref from students s
group by s.student_population_code_ref 

-- 4. calculate age from dob
select *, date_part('year', age(contact_birthdate)) as contact_age from contacts c 

-- 5. add age column to contacts
alter table contacts add contact_age integer null;

-- 6. calculate age from dob and insert in col con_age
update contacts as c1 set contact_age = 
(select date_part('year', age(contact_birthdate)) as con_age
from contacts c2 where c1.contact_email = c2.contact_email);

-- 7. avg student age
select avg(contact_age) as avg_student_age from students s 
left join contacts c on s.student_contact_ref = c.contact_email 

-- 8. avg session duration for a course
select avg(EXTRACT(EPOCH FROM TO_TIMESTAMP(session_end_time, 'HH24:MI:SS')::TIME - TO_TIMESTAMP(session_start_time, 'HH24:MI:SS')::TIME)/3600) as duration 
from sessions as s 
left join courses as c on c.course_code=s.session_course_ref
where c.course_code='DT_RDBMS'

-- 9. find the student with most absents
select c.contact_first_name, c.contact_last_name, count(a.attendance_student_ref) as absents from contacts c 
left join students s on s.student_contact_ref = c.contact_email 
left join attendance a on a.attendance_student_ref = s.student_epita_email 
where a.attendance_presence = 0
group by c.contact_first_name, c.contact_last_name 
order by absents desc
limit 1;

-- 10. find the course with most absents
select c.course_name, count(a.attendance_presence) absents from attendance a 
left join courses c on a.attendance_course_ref = c.course_code 
where a.attendance_presence = 0
group by a.attendance_course_ref, c.course_name 
order by absents desc
limit 1;
-- 11. find a students who are not graded
select s.student_epita_email, g.grade_score from students s 
left join grades g on g.grade_student_epita_email_ref = s.student_epita_email 
where g.grade_score is null;

-- 12. find the teachers who are not in any session
select c.contact_first_name, c.contact_last_name, t.teacher_epita_email from contacts c 
inner join teachers t on t.teacher_contact_ref = c.contact_email 
left join sessions s on s.session_prof_ref = t.teacher_epita_email 
where s.session_prof_ref is null;

select t.teacher_epita_email from teachers t 
left join sessions s on s.session_prof_ref = t.teacher_epita_email 
where s.session_prof_ref is null;

-- 13. list of teacher who attend the total session
select c.contact_first_name, c.contact_last_name, t.teacher_contact_ref, count(s.session_prof_ref)from teachers t
inner join contacts c on c.contact_email = t.teacher_contact_ref 
inner join sessions s on s.session_prof_ref = t.teacher_epita_email 
group by c.contact_first_name, c.contact_last_name, t.teacher_contact_ref
order by count(s.session_prof_ref) desc


-- 14. find the DSA students details with grades
select c.contact_first_name, c.contact_last_name, s.student_population_code_ref,g.grade_course_code_ref, g.grade_score from grades g 
inner join students s on s.student_epita_email = g.grade_student_epita_email_ref 
inner join contacts c on  c.contact_email = s.student_contact_ref 
where s.student_population_code_ref = 'DSA'
order by g.grade_score desc;

-- 15. attendance percentage for a student
select a.attendance_student_ref, a.attendance_course_ref, 
(sum(a.attendance_presence)/count(1)::float)* 100 as percentage
from attendance a 
where a.attendance_student_ref = 'jamal.vanausdal@epita.fr'
group by a.attendance_student_ref, a.attendance_course_ref;

-- 16. avg grade for DSA students
select avg(g.grade_score) as avg_grade, p2.population_code as population from grades g 
inner join programs p on p.program_course_code_ref = g.grade_course_code_ref 
inner join populations p2 on p2.population_code = p.program_assignment 
where p2.population_code = 'DSA'
group by p2.population_code 

-- 17. All student average grade
select c.contact_first_name, c.contact_last_name,s.student_epita_email,avg(g.grade_score) from students s 
inner join contacts c on c.contact_email = s.student_contact_ref 
inner join grades g on g.grade_student_epita_email_ref = s.student_epita_email 
group by c.contact_first_name, c.contact_last_name, s.student_epita_email 

-- 18. list the course tought by teacher
select distinct c.contact_first_name, c.contact_last_name, s.session_course_ref from teachers t 
inner join contacts c on c.contact_email = t.teacher_contact_ref 
inner join sessions s on s.session_prof_ref = t.teacher_epita_email 

-- 19. find the teachers who are not giving any courses
select c2.contact_first_name, c2.contact_last_name, t.teacher_epita_email from teachers t
left join contacts c2 on c2.contact_email = t.teacher_contact_ref 
left join sessions s on s.session_prof_ref = t.teacher_epita_email 
left join courses c on c.course_code = s.session_course_ref 
where s.session_course_ref is null

--1 get all enrolled students for a specific period, program, year
select * from students s
where s.student_population_period_ref = 'SPRING' 
and s.student_population_year_ref = '2021'
and s.student_population_code_ref = 'DSA'

--2 get number of enrolled studnets for a specific period, program, year
select count(1) from students s
where s.student_population_period_ref = 'SPRING' 
and s.student_population_year_ref = '2021'
and s.student_population_code_ref = 'DSA'

--3 get all defined exams for a course from grades table
select distinct g.grade_exam_type_ref from grades g 

--4 get all grades for a student
select c.course_name, g.grade_exam_type_ref, g.grade_score from grades g
inner join courses c on c.course_code = g.grade_course_code_ref 
and c.course_rev = g.grade_course_rev_ref
where g.grade_student_epita_email_ref = 'marjory.mastella@epita.fr'

--5 get all grades for a specific exam
select distinct g.grade_course_code_ref, g.grade_score  from grades g 
where g.grade_course_code_ref = 'SE_ADV_JS' and g.grade_exam_type_ref = 'Project'
order by g.grade_score desc

--6 get students ranks in an exam for a course
select g.grade_student_epita_email_ref, g.grade_course_code_ref, g.grade_score, 
dense_rank() over(order by g.grade_score desc) student_rank from grades g 
where g.grade_course_code_ref = 'PG_PYTHON' and g.grade_exam_type_ref = 'Project';

--7 get students ranks in all exams for a course
select g.grade_student_epita_email_ref, g.grade_course_code_ref, g.grade_exam_type_ref, g.grade_score,
dense_rank() over(partition by g.grade_exam_type_ref order by g.grade_score desc) student_rank
from grades g  
where g.grade_course_code_ref = 'SE_ADV_JAVA'

--8 get students rank in all exams in all courses
select g.grade_student_epita_email_ref, g.grade_course_code_ref, g.grade_exam_type_ref, g.grade_score,
dense_rank() over(partition by g.grade_course_code_ref, g.grade_exam_type_ref order by g.grade_score desc) student_rank
from grades g 

--9 get all courses for one program 
select c.course_name, c.course_code from courses c 
left join programs p on p.program_course_code_ref = c.course_code 
where p.program_assignment = 'DSA'
 
--10 get courses in common between 2programs
select c.course_name, c.course_code from courses c 
left join programs p on p.program_course_code_ref = c.course_code and p.program_course_rev_ref = c.course_rev
where p.program_assignment = 'SE'
intersect 
select c.course_name, c.course_code from courses c 
left join programs p on p.program_course_code_ref = c.course_code and p.program_course_rev_ref = c.course_rev
where p.program_assignment = 'DSA'

--11 get all programs following a certain course
select p.program_assignment from programs p 
where p.program_course_code_ref = 'AI_DATA_SCIENCE_IN_PROD'

--12 get course with the biggest duration
select * from courses c 
order by c.duration desc
limit 2

with course_duration_rank as (
select c.course_name,  duration,
rank() over(order by duration desc) as rnk
from courses c
)
select duration ,course_name, rnk
from course_duration_rank
where rnk = 1;

--13 get courses with the same duration

select course_name, duration from courses where duration in (
select duration from courses
group by duration having count(*) > 1
)
order by duration desc

--14 get all sessions for a specific course

select s.session_course_ref, s.session_type, s.session_date from sessions s 
where s.session_course_ref = 'AI_DATA_PREP';

--15 get all session for a certain period 
select * from sessions s 
where s.session_date between '2020-11-26' and '2021-02-04' 
and s.session_course_ref = 'AI_DATA_PREP'

--16 get one student attendance sheet
select c.contact_first_name, c.contact_last_name,  a.attendance_session_date_ref, a.attendance_course_ref, a.attendance_presence from students s
left join attendance a on a.attendance_student_ref = s.student_epita_email 
left join contacts c on c.contact_email = s.student_contact_ref 
where s.student_epita_email = 'jamal.vanausdal@epita.fr'

--17 get one student summery of attendance
-- 18 Get student with most absences
select c.contact_first_name, c.contact_last_name, count(a.attendance_presence) as absents from students s
left join contacts c on c.contact_email = s.student_contact_ref
left join attendance a on s.student_epita_email = a.attendance_student_ref
where a.attendance_presence = 0
group by c.contact_first_name, c.contact_last_name
order by absents desc
limit 1


--hard question
--1- Get all exams for a specific Course
select * from exams e 
where exam_course_code = 'CS_SOFTWARE_SECURITY'

--2- Get all Grades for a specific Student
select c.contact_first_name, c.contact_last_name, s.student_population_code_ref, g.grade_course_code_ref, g.grade_score from grades g 
inner join students s on s.student_epita_email = g.grade_student_epita_email_ref 
inner join contacts c on s.student_contact_ref = c.contact_email 
where s.student_epita_email = 'jamal.vanausdal@epita.fr'
order by g.grade_score desc;

--3- Get the final grades for a student on a specifique course or all courses
select c.contact_first_name, c.contact_last_name, g.grade_course_code_ref, sum(e.exam_weight * g.grade_score)/sum(e.exam_weight) as final_grade from grades g
left join exams e on e.exam_course_code = g.grade_course_code_ref 
left join students s on g.grade_student_epita_email_ref = s.student_epita_email 
left join contacts c on s.student_contact_ref = c.contact_email 
where g.grade_student_epita_email_ref = 'jamal.vanausdal@epita.fr' 
and e.exam_course_code = 'DT_RDBMS'
group by c.contact_first_name, c.contact_last_name, g.grade_course_code_ref 


--4-Get the students with the top 5 scores for specific course

with total_grade_course as (
select c.contact_first_name, c.contact_last_name ,g.grade_course_code_ref, sum(e.exam_weight * g.grade_score)/sum(e.exam_weight) as total_grade,
rank() over (partition by g.grade_course_code_ref order by sum(e.exam_weight * g.grade_score)/sum(e.exam_weight) desc) as rnk
from grades g
left join exams e on g.grade_course_code_ref = e.exam_course_code
left join students s on g.grade_student_epita_email_ref = s.student_epita_email
left join contacts c on s.student_contact_ref = c.contact_email
group by g.grade_course_code_ref, c.contact_first_name, c.contact_last_name
)
select contact_first_name, contact_last_name, grade_course_code_ref, total_grade, rnk
from total_grade_course
where rnk <=5 and grade_course_code_ref ='DT_RDBMS'


--5-Get the students with the top 5 scores for specific course per rank


--6-Get the Class average for a course
select g.grade_course_code_ref, (sum(e.exam_weight * g.grade_score)/sum(e.exam_weight)::float) as class_average
from grades g inner join exams e on g.grade_course_code_ref = e.exam_course_code
inner join students s on g.grade_student_epita_email_ref =s.student_epita_email
where g.grade_course_code_ref = 'AI_DATA_PREP'
group by g.grade_course_code_ref;

--simple query : get all the contacts from Anchorage, display the columns contact email, firstname and city ordered by contact_firstname
select c.contact_email, c.contact_first_name, c.contact_city from contacts c 
order by c.contact_first_name desc;
	
--intermediate query : find all the teachers who haven't taught at all, return the teacher email addresses, in ascending order
select t.teacher_epita_email from teachers t 
left join sessions s on s.session_prof_ref = t.teacher_epita_email 
left join courses c on c.course_code = s.session_course_ref 
where c.course_code is null
order by t.teacher_epita_email asc;

--harder query : compute the absence rate per student and per course, ordered by student epita_email ascending, course name ascending and absence rate descending
select a.attendance_student_ref, a.attendance_course_ref, 
to_char(((sum(a.attendance_presence)/count(1)::float)*100),'999D99%') as absence_rate
from attendance a 
group by a.attendance_student_ref, a.attendance_course_ref
order by a.attendance_student_ref asc, a.attendance_course_ref asc;
 

