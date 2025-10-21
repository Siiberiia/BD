-- Создание базы данных и таблиц
create database university_db;

-- Создание таблиц
create table groups (
    id serial primary key,
    code varchar not null,
    course integer not null check (course between 1 and 4)
);

create table students (
    id serial primary key,
    last_name varchar not null,
    first_name varchar not null,
    middle_name varchar,
    gender varchar check (gender in ('М', 'Ж')),
    birth_date date,
    group_id integer not null,
    foreign key (group_id) references groups(id)
);

create table subjects (
    id serial primary key,
    name varchar not null,
    report_type varchar check (report_type in ('rating', 'exam', 'paper'))
);

create table marks (
    student_id integer not null,
    subject_id integer not null,
    semester_number integer check (semester_number between 1 and 8),
    grade integer check (grade between 2 and 5),
    primary key (student_id, subject_id, semester_number),
    foreign key (student_id) references students(id),
    foreign key (subject_id) references subjects(id)
);

-- Заполнение тестовыми данными
insert into groups (code, course) values
('ИТПМ-121', 1),
('ИТПМ-122', 2),
('ИТПМ-123', 3),
('ИТПМ-124', 4),
('ИТПМ-125', 1),
('ИТПМ-126', 2);

insert into students (last_name, first_name, middle_name, gender, birth_date, group_id) values
('Иванов', 'Иван', 'Иванович', 'М', '2000-01-15', 1),
('Петров', 'Петр', 'Петрович', 'М', '1999-03-20', 2),
('Сидорова', 'Мария', 'Сергеевна', 'Ж', '2000-05-10', 3),
('Кузнецов', 'Алексей', 'Дмитриевич', 'М', '1998-12-05', 4),
('Смирнов', 'Давид', 'Олегович', 'М', '1999-07-15', 4),
('Попова', 'Ольга', 'Игоревна', 'Ж', '2000-02-28', 3),
('Васильев', 'Степан', 'Александрович', 'М', '1998-11-10', 4),
('Николаева', 'Елена', 'Владимировна', 'Ж', '2000-08-22', 3),
('Федоров', 'Давид', 'Сергеевич', 'М', '1997-05-30', 4),
('Орлова', 'Анна', 'Петровна', 'Ж', '2000-04-12', 3);

insert into subjects (name, report_type) values
('Математика', 'exam'),
('Физика', 'exam'),
('Программирование', 'rating'),
('Базы данных', 'exam'),
('Защита информации', 'paper'),
('Дифференциальные уравнения', 'exam'),
('Алгоритмы', 'rating'),
('Сети', 'exam');

insert into marks (student_id, subject_id, semester_number, grade) values
(1, 1, 1, 4), (1, 2, 1, 5), (1, 3, 1, 4),
(2, 1, 2, 3), (2, 2, 2, 4), (2, 4, 2, 5),
(3, 1, 3, 5), (3, 2, 3, 5), (3, 4, 3, 2),
(4, 1, 4, 4), (4, 2, 4, 5), (4, 5, 4, 4),
(5, 6, 4, 5), (5, 1, 4, 4), (5, 2, 4, 5),
(6, 1, 3, 5), (6, 4, 3, 2), (6, 7, 3, 2),
(7, 1, 1, 3), (7, 2, 1, 4), (7, 6, 4, 4),
(8, 1, 3, 5), (8, 2, 3, 5), (8, 4, 3, 5),
(9, 6, 4, 5), (9, 1, 4, 5), (9, 2, 4, 5),
(10, 1, 3, 5), (10, 2, 3, 5), (10, 4, 3, 5);

-- Запросы для заданий 1-20

-- 1. Выбрать всех студентов 3 курса
select s.* 
from students s
join groups g on s.group_id = g.id
where g.course = 3;

-- 2. Выбрать все группы, в которых хотя бы 10 студентов
select g.*, count(s.id) as student_count
from groups g
join students s on g.id = s.group_id
group by g.id, g.code, g.course
having count(s.id) >= 10;

-- 3. Выбрать названия всех предметов, по которым средний балл по экзамену за 4 семестр превышает 3.5
select s.name, avg(m.grade) as average_grade
from subjects s
join marks m on s.id = m.subject_id
where m.semester_number = 4 and s.report_type = 'exam'
group by s.id, s.name
having avg(m.grade) > 3.5;

-- 4. Выбрать первых 10 студентов, которые сдали все экзамены в 3 семестре на 5
select s.*
from students s
where not exists (
    select 1
    from marks m
    join subjects sub on m.subject_id = sub.id
    where m.student_id = s.id 
    and m.semester_number = 3 
    and sub.report_type = 'exam'
    and m.grade < 5
)
limit 10;

-- 5. Выбрать все уникальные предметы, которые проводятся на 3-4 курсе и по которым сдаётся курсовая
select distinct s.*
from subjects s
join marks m on s.id = m.subject_id
join students st on m.student_id = st.id
join groups g on st.group_id = g.id
where g.course in (3, 4) and s.report_type = 'paper';

-- 6. Выбрать все номера семестров, за которые у группы с названием "ИТПМ-124" хотя бы у трёх студентов средний балл за экзамены, сданные в этот семестр, превышает 4.5
select m.semester_number
from marks m
join students s on m.student_id = s.id
join groups g on s.group_id = g.id
join subjects sub on m.subject_id = sub.id
where g.code = 'ИТПМ-124' and sub.report_type = 'exam'
group by m.semester_number
having count(distinct case when (
    select avg(m2.grade) 
    from marks m2 
    join subjects sub2 on m2.subject_id = sub2.id 
    where m2.student_id = s.id 
    and m2.semester_number = m.semester_number 
    and sub2.report_type = 'exam'
) > 4.5 then s.id end) >= 3;

-- 7. Найти 5 самых старших студентов мужского пола со 2 и 4 курса
select s.*
from students s
join groups g on s.group_id = g.id
where s.gender = 'М' and g.course in (2, 4)
order by s.birth_date asc
limit 5;

-- 8. Найти все предметы, по которым средний балл у группы "ИТПМ-124" между 3.0 и 4.0
select s.name, avg(m.grade) as average_grade
from subjects s
join marks m on s.id = m.subject_id
join students st on m.student_id = st.id
join groups g on st.group_id = g.id
where g.code = 'ИТПМ-124'
group by s.id, s.name
having avg(m.grade) between 3.0 and 4.0;

-- 9. Найти фамилии всех студентов, которые не сдали предмет "Базы данных" в 3 семестре
select s.last_name, s.first_name
from students s
join marks m on s.id = m.student_id
join subjects sub on m.subject_id = sub.id
where sub.name = 'Базы данных' 
and m.semester_number = 3 
and m.grade = 2;

-- 10. Найти всех студентов, сдавших курсовую работу по предмету "Защита информации" в 4 семестре
select s.*
from students s
join marks m on s.id = m.student_id
join subjects sub on m.subject_id = sub.id
where sub.name = 'Защита информации' 
and sub.report_type = 'paper'
and m.semester_number = 4 
and m.grade >= 3;

-- 11. Найти всех студентов, которые не сдали хотя бы один экзамен
select distinct s.*
from students s
join marks m on s.id = m.student_id
join subjects sub on m.subject_id = sub.id
where sub.report_type = 'exam' and m.grade = 2;

-- 12. Найти все группы, в которых есть хотя бы один должник по курсовой работе
select distinct g.*
from groups g
join students s on g.id = s.group_id
join marks m on s.id = m.student_id
join subjects sub on m.subject_id = sub.id
where sub.report_type = 'paper' and m.grade = 2;

-- 13. Найти все предметы, по которым есть хотя бы один должник, не сдавший ещё какой-либо другой предмет
select distinct sub1.*
from subjects sub1
join marks m1 on sub1.id = m1.subject_id
where m1.grade = 2
and exists (
    select 1
    from marks m2
    join subjects sub2 on m2.subject_id = sub2.id
    where m2.student_id = m1.student_id
    and m2.grade = 2
    and sub2.id != sub1.id
);

-- 14. Найти статистику сдачи сессии группы ИТПМ-124, отсортировав фамилии студентов по невозрастанию среднего балла за все предметы третьего семестра
select s.last_name, s.first_name, avg(m.grade) as average_grade
from students s
join marks m on s.id = m.student_id
join groups g on s.group_id = g.id
where g.code = 'ИТПМ-124' and m.semester_number = 3
group by s.id, s.last_name, s.first_name
order by average_grade desc;

-- 15. Найти средний балл по экзамену по предмету "Дифференциальные уравнения" всех студентов, которых зовут "Давид"
select avg(m.grade) as average_grade
from marks m
join students s on m.student_id = s.id
join subjects sub on m.subject_id = sub.id
where sub.name = 'Дифференциальные уравнения' 
and sub.report_type = 'exam'
and s.first_name = 'Давид';

-- 16. Найти средние баллы по всем прошедшим сессиям для студентов, у которых в имени есть подстрока "Степан"
select s.last_name, s.first_name, m.semester_number, avg(m.grade) as average_grade
from students s
join marks m on s.id = m.student_id
where s.first_name like '%Степан%'
group by s.id, s.last_name, s.first_name, m.semester_number
order by s.last_name, m.semester_number;

-- 17. Получить выборку из всех предметов, которые не сдала минимум половина студентов какой-либо группы
select sub.name, g.code, 
       count(distinct s.id) as total_students,
       count(distinct case when m.grade = 2 then s.id end) as failed,
       round(count(distinct case when m.grade = 2 then s.id end) * 100.0 / count(distinct s.id), 2) as failed_percentage
from subjects sub
join marks m on sub.id = m.subject_id
join students s on m.student_id = s.id
join groups g on s.group_id = g.id
group by sub.id, sub.name, g.id, g.code
having count(distinct case when m.grade = 2 then s.id end) >= count(distinct s.id) * 0.5;

-- 18. Найти все предметы, по которым сдаётся рейтинг и по нему есть по крайней мере 5 должников
select sub.name, count(distinct m.student_id) as debtors_count
from subjects sub
join marks m on sub.id = m.subject_id
where sub.report_type = 'rating' and m.grade = 2
group by sub.id, sub.name
having count(distinct m.student_id) >= 5;

-- 19. Получить средние баллы по всем предметам для студентов, успешно сдавших все 8 семестров
select s.last_name, s.first_name, sub.name, avg(m.grade) as average_grade
from students s
join marks m on s.id = m.student_id
join subjects sub on m.subject_id = sub.id
where s.id in (
    select student_id
    from marks
    group by student_id
    having count(distinct semester_number) = 8
    and min(grade) >= 3
)
group by s.id, s.last_name, s.first_name, sub.id, sub.name
order by s.last_name, s.first_name, sub.name;

-- 20. Получить всех студентов, которые успешно сдали 3 семестр, но не сдали что-либо из первого либо второго семестра
select s.*
from students s
where not exists (
    select 1
    from marks m
    where m.student_id = s.id 
    and m.semester_number = 3 
    and m.grade = 2
)
and exists (
    select 1
    from marks m
    where m.student_id = s.id 
    and m.semester_number in (1, 2) 
    and m.grade = 2
);