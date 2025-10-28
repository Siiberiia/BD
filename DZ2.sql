CREATE DATABASE bonuses_part_3;

CREATE TABLE IF NOT EXISTS public.service
(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.subscription
(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price MONEY NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.client
(
    id SERIAL NOT NULL PRIMARY KEY,
    surname VARCHAR(150) NOT NULL,
    name VARCHAR(150) NOT NULL,
    sex BOOL NOT NULL,
    birthday DATE NOT NULL,
    subscription_id INT NOT NULL,
    subscription_start DATE NOT NULL,
    subscription_end DATE NOT NULL,
    FOREIGN KEY(subscription_id) REFERENCES public.subscription(id)
);

CREATE TABLE IF NOT EXISTS public.sub_to_service
(
    sub_id INT NOT NULL,
    service_id INT NOT NULL,
    PRIMARY KEY (sub_id, service_id),
    FOREIGN KEY(sub_id) REFERENCES public.subscription(id),
    FOREIGN KEY(service_id) REFERENCES public.service(id)
);

-- Заполнение таблицы service
INSERT INTO public.service (name) VALUES
('отчислиться на АиСД'),
('ПМИ'),
('Бонусы для 2 курса'),
('Математика'),
('Программирование'),
('Базы данных'),
('Алгоритмы и структуры данных'),
('Веб-разработка'),
('Мобильная разработка'),
('Искусственный интеллект'),
('отчислиться из МАИ'),
('Компьютерные сети'),
('Операционные системы'),
('Кибербезопасность'),
('Разработка игр');

-- Заполнение таблицы subscription
INSERT INTO public.subscription (name, price, description) VALUES
('demo_sub', 0, 'Демонстрационная подписка с ограниченным доступом'),
('student_basic', 25000, 'Базовая подписка для студентов'),
('student_premium', 52000, 'Премиум подписка для студентов с расширенным доступом'),
('professional', 85000, 'Профессиональная подписка для разработчиков'),
('enterprise', 120000, 'Корпоративная подписка с полным доступом ко всем услугам'),
('vip', 150000, 'VIP подписка с персональной поддержкой'),
('trial', 10000, 'Пробная подписка на 1 месяц'),
('alumni', 45000, 'Специальная подписка для выпускников');

-- Заполнение таблицы sub_to_service (связь подписок и услуг)
INSERT INTO public.sub_to_service (sub_id, service_id) VALUES
-- demo_sub (базовые услуги)
(1, 2), (1, 4), (1, 5),
-- student_basic (студенческие услуги)
(2, 2), (2, 3), (2, 4), (2, 5), (2, 6),
-- student_premium (расширенные студенческие)
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7),
-- professional (профессиональные услуги)
(4, 2), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 9), (4, 10),
-- enterprise (все услуги)
(5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8), (5, 9), (5, 10), (5, 11), (5, 12), (5, 13), (5, 14), (5, 15),
-- vip (избранные премиум услуги)
(6, 1), (6, 2), (6, 10), (6, 11), (6, 14), (6, 15),
-- trial (ограниченный пробный доступ)
(7, 2), (7, 4), (7, 5),
-- alumni (для выпускников)
(8, 2), (8, 4), (8, 5), (8, 6), (8, 7), (8, 10);

-- Заполнение таблицы client
INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Мужчины (true)
('Петров', 'Алексей', true, '1998-08-20', 2, '2024-06-01', '2025-06-01'),
('Сидоров', 'Дмитрий', true, '1990-03-10', 3, '2024-03-15', '2024-12-15'),
('Кузнецов', 'Сергей', true, '1985-11-25', 4, '2024-01-10', '2025-01-10'),
('Васильев', 'Михаил', true, '1988-12-05', 5, '2024-02-20', '2025-02-20'),
('Николаев', 'Андрей', true, '1992-07-30', 6, '2024-04-01', '2025-04-01'),
('Федоров', 'Павел', true, '1987-09-14', 4, '2024-05-15', '2025-05-15'),
('Морозов', 'Владимир', true, '1993-02-28', 3, '2024-03-01', '2024-09-01'),
('Волков', 'Евгений', true, '1983-06-18', 2, '2024-01-20', '2025-01-20'),
('Семенов', 'Константин', true, '1991-04-12', 5, '2024-02-10', '2025-02-10');

INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Женщины (false)
('Иванова', 'Мария', false, '1996-05-15', 1, '2024-01-01', '2024-12-31'),
('Петрова', 'Ольга', false, '1999-08-20', 2, '2024-06-01', '2025-06-01'),
('Сидорова', 'Елена', false, '1991-03-10', 3, '2024-03-15', '2024-12-15'),
('Кузнецова', 'Анна', false, '1986-11-25', 4, '2024-01-10', '2025-01-10'),
('Васильева', 'Наталья', false, '1989-12-05', 5, '2024-02-20', '2025-02-20'),
('Николаева', 'Ирина', false, '1993-07-30', 6, '2024-04-01', '2025-04-01'),
('Федорова', 'Светлана', false, '1988-09-14', 4, '2024-05-15', '2025-05-15'),
('Морозова', 'Татьяна', false, '1994-02-28', 3, '2024-03-01', '2024-09-01'),
('Волкова', 'Юлия', false, '1984-06-18', 2, '2024-01-20', '2025-01-20'),
('Семенова', 'Екатерина', false, '1992-04-12', 5, '2024-02-10', '2025-02-10');

INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Дополнительные клиенты для статистики
('Попов', 'Артем', true, '1997-08-12', 3, '2024-07-01', '2025-07-01'),
('Соколов', 'Роман', true, '1980-11-03', 5, '2024-08-15', '2025-08-15'),
('Лебедева', 'Алиса', false, '1995-12-22', 4, '2024-09-10', '2025-09-10'),
('Козлов', 'Игорь', true, '1982-04-17', 6, '2024-10-05', '2025-10-05'),
('Новикова', 'Дарья', false, '1998-07-08', 2, '2024-11-20', '2025-11-20'),
('Медведев', 'Александр', true, '1979-01-30', 5, '2024-12-01', '2025-12-01'),
('Павлова', 'Виктория', false, '1994-03-25', 3, '2024-06-15', '2025-06-15'),
('Соловьев', 'Максим', true, '1987-10-11', 4, '2024-05-20', '2025-05-20'),
('Воробьева', 'Полина', false, '1996-09-14', 1, '2024-04-10', '2025-04-10'),
('Фролов', 'Георгий', true, '1981-02-28', 6, '2024-03-05', '2025-03-05');

INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Клиенты с подпиской, заканчивающейся в 2025 году (для задания 2)
('Громов', 'Станислав', true, '1990-06-15', 3, '2024-01-01', '2025-12-31'),
('Тихонова', 'Людмила', false, '1988-08-22', 4, '2024-02-01', '2025-11-15'),
('Белов', 'Арсений', true, '1993-04-18', 5, '2024-03-01', '2025-10-20');

INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Клиенты с подпиской на "ПМИ" до 3 ноября 2025 (для задания 8)
('Орлов', 'Виталий', true, '1991-07-07', 3, '2024-01-01', '2025-11-03'),
('Зайцева', 'Маргарита', false, '1989-05-12', 4, '2024-02-01', '2025-11-03'),
('Ершов', 'Григорий', true, '1994-12-03', 5, '2024-03-01', '2025-11-03');

INSERT INTO public.client (surname, name, sex, birthday, subscription_id, subscription_start, subscription_end) VALUES
-- Клиенты с просроченной подпиской (для задания 7)
('Макаров', 'Борис', true, '1985-09-28', 1, '2023-01-01', '2023-12-31'),
('Андреева', 'Валерия', false, '1992-11-14', 2, '2023-03-01', '2023-09-01'),
('Григорьев', 'Тимур', true, '1987-02-19', 3, '2023-06-01', '2023-12-01');

-- 1. Выбрать уникальные фамилии всех клиентов с подпиской с названием "demo_sub"
select distinct c.surname
from client c
join subscription s on c.subscription_id = s.id
where s.name = 'demo_sub';

-- 2. Выбрать всех клиентов, подписка которых заканчивается в текущем году
select *
from client
where extract(year from subscription_end) = extract(year from current_date);

-- 3. Выбрать все подписки, которыми пользуются хотя бы 10 клиентов
select s.*, count(c.id) as client_count
from subscription s
join client c on s.id = c.subscription_id
group by s.id, s.name, s.price, s.description
having count(c.id) >= 10;

-- 4. Выбрать все подписки, содержащие больше 5 различных услуг
select s.*, count(sts.service_id) as service_count
from subscription s
join sub_to_service sts on s.id = sts.sub_id
group by s.id, s.name, s.price, s.description
having count(sts.service_id) > 5;

-- 5. Выбрать фамилии и имена всех мужчин, у которых в подписке есть услуга с названием "отчислиться на АиСД"
select c.name, c.surname
from public.client c
inner join subscription s on c.subscription_id = s.id
inner join sub_to_service sts on s.id = sts.sub_id
inner join service serv on sts.service_id = serv.id
where c.sex = true
    and  serv.name = 'отчислиться на АиСД';

-- 6. Построить полное соответствие услуг всем подпискам
select s.name as subscription_name, sr.name as service_name
from subscription s
left join sub_to_service sts on s.id = sts.sub_id
left join service sr on sts.service_id = sr.id
order by s.name, sr.name;

-- 7. Выбрать всех клиентов, у которых на текущий момент времени просрочена подписка
select *
from client
where subscription_end < current_date;

-- 8. Выбрать фамилии и имена всех клиентов, у которых подписка на услугу "ПМИ" закончится 3 ноября 2025 года
select c.name, c.surname
    from public.client c
    inner join public.subscription s
        on c.subscription_id = s.id
    where s.name = 'ПМИ'
        and c.subscription_end = '03.11.2025'::DATE;

-- 9. Выбрать всех клиентов, подписка которых стоит дороже 52000 у. е.
select c.*
from client c
join subscription s on c.subscription_id = s.id
where s.price::numeric > 52000;

-- 10. Выбрать всех женщин, подписка которых содержит услугу с id = 3
select distinct c.*
from client c
join sub_to_service sts on c.subscription_id = sts.sub_id
where c.sex = false and sts.service_id = 3;

-- 11. Реализовать представление, возвращающее все активные сервисы
create view active_services as
select distinct s.*
from service s
join sub_to_service sts on s.id = sts.service_id
join subscription sub on sts.sub_id = sub.id
join client c on sub.id = c.subscription_id
where c.subscription_end >= current_date;

-- 12. Написать запрос, назначающий пользователю новую подписку по её id
update client 
set subscription_id = 2, 
    subscription_start = current_date, 
    subscription_end = current_date + interval '1 year'
where id = 1;

-- 13. Написать запрос, назначающий пользователю новую подписку по её названию
update client 
set subscription_id = (select id from subscription where name = 'premium'),
    subscription_start = current_date,
    subscription_end = current_date + interval '1 year'
where id = 1;

-- 14. Вычислить количество мужчин старше 35 лет, потенциально пользующихся услугой с названием "Бонусы для 2 курса"
SELECT COUNT(*)
  from public.client c
    inner join public.subscription su on c.subscription_id = su.id
    inner join public.sub_to_service sts on su.id = sts.sub_id
    inner join public.service se on sts.service_id = se.id
  where extract(year from (NOW() - c.birthday)) > 35
    and su.name = 'Бонусы для 2 курса'
    and c.sex = true;

-- 15. Найти все подписки, стоимость которых превышает 85000 у. е., содержащих не более 10 услуг и которыми пользуются хотя бы 10 мужчин и 10 женщин
select s.*
from subscription s
where s.price::numeric > 85000
and (
    select count(sts.service_id) 
    from sub_to_service sts 
    where sts.sub_id = s.id
) <= 10
and (
    select count(distinct c.id) 
    from client c 
    where c.subscription_id = s.id and c.sex = true
) >= 10
and (
    select count(distinct c.id) 
    from client c 
    where c.subscription_id = s.id and c.sex = false
) >= 10;