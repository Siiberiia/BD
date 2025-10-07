-- задание 1: операции с авторами
-- добавление автора
insert into public.author (last_name, first_name) values ('Гоголь', 'Николай') returning id;
-- редактирование автора по id
update public.author 
set last_name = 'Тургенев', first_name = 'Иван'
where id = 1;
-- удаление автора по id
delete from public.author where id = 1;

-- задание 2: операции с издательствами
-- добавление издательства
insert into public.publishing_house (name, city) values ('Дрофа', 'Москва') returning id;
-- редактирование издательства
update public.publishing_house 
set name = 'Новое издательство', city = 'Санкт-Петербург'
where id = 1;
-- удаление издательства
delete from public.publishing_house where id = 1;

-- задание 3: операции с книгами
-- добавление книги
insert into public.book (title, author_id, publishing_house_id, publication_year) 
values ('Мертвые души', 4, 4, 2022) returning id;
-- редактирование книги
update public.book 
set title = 'Трупы', publication_year = 2023
where id = 1;
-- удаление книги
delete from public.book where id = 1;

-- задание 4: операции с читателями
-- добавление читателя
insert into public.reader (last_name, first_name, birth_date, gender, registration_date)
values ('Козлов', 'Дмитрий', '1988-03-10', 'М', '2024-03-10') returning ticket_number;
-- редактирование читателя
update public.reader 
set last_name = 'Смирнов', first_name = 'Павел', gender = 'М'
where ticket_number = 1;
-- удаление читателя
delete from public.reader where ticket_number = 1;

-- задание 5: операции с экземплярами книг
-- добавление экземпляра книги
insert into public.book_instance (inventory_number, book_id, state, status, section, line, bookshelf)
values ('inv-005', 4, 'отличное', 'в наличии', 'г', '1', '1') returning inventory_number;
-- редактирование экземпляра книги
update public.book_instance 
set state = 'хорошее', status = 'в наличии', section = 'д'
where inventory_number = 'inv-001';
-- удаление экземпляра книги
delete from public.book_instance where inventory_number = 'inv-001';

-- задание 6: выдача книги
insert into public.issuance (reader_ticket_number, book_instance_number, issue_datetime, expected_return_date)
values ('1', 'inv-001', current_timestamp, current_date + interval '14 days');

update public.book_instance set status = 'выдана' where inventory_number = 'inv-001';

-- задание 7: возврат книги
update public.issuance 
set actual_return_date = current_date
where reader_ticket_number = '1' and book_instance_number = 'inv-001';

update public.book_instance set status = 'в наличии' where inventory_number = 'inv-002';

-- задание 8: представление выданных книг
create view public.issued_books_view as
select 
    r.last_name || ' ' || r.first_name as reader_name,
    a.last_name || ' ' || a.first_name as author_name,
    b.title as book_title,
    bi.state as book_condition,
    i.issue_datetime
from public.issuance i
join public.reader r on i.reader_ticket_number = r.ticket_number
join public.book_instance bi on i.book_instance_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null;

select * from public.issued_books_view;

-- задание 9: представление просроченных выдач
create view public.overdue_issues_view as
select 
    i.reader_ticket_number,
    r.last_name || ' ' || r.first_name as reader_name,
    a.last_name || ' ' || a.first_name as author_name,
    b.title as book_title,
    (current_date - i.expected_return_date) as overdue_days
from public.issuance i
join public.reader r on i.reader_ticket_number = r.ticket_number
join public.book_instance bi on i.book_instance_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null and current_date > i.expected_return_date;

select * from public.overdue_issues_view;

-- задание 10: выдача с проверкой просрочек
insert into public.issuance (reader_ticket_number, book_instance_number, issue_datetime, expected_return_date)
select '2', 'inv-003', current_timestamp, current_date + interval '14 days'
where not exists (select 1 from public.overdue_issues_view where reader_ticket_number = '2');
-- обновление статуса книги, если она была выдана
update public.book_instance 
set status = 'выдана' 
where inventory_number = 'inv-003'
  and exists (
    select 1 from public.issuance 
    where reader_ticket_number = '2' 
      and book_instance_number = 'inv-003' 
      and actual_return_date is null);


-- задание 11: бронирование книги
with available_copy as (
    select bi.inventory_number
    from public.book_instance bi
    where bi.book_id = 1
      and bi.state >= 'хорошее'::book_state
      and bi.status = 'в наличии'
      and not exists (
        select 1 from public.issuance i 
        where i.book_instance_number = bi.inventory_number 
        and i.actual_return_date is null
      )
      and not exists (
        select 1 from public.booking b 
        where b.book_instance_number = bi.inventory_number
        and current_timestamp <= b.booking_datetime::date + interval '3 days'
      )
    order by 
      case bi.state
        when 'отличное' then 1
        when 'хорошее' then 2
        when 'удовлетворительное' then 3
        else 4
      end
    limit 1
)
insert into public.booking (reader_ticket_number, book_id, book_instance_number, min_condition_level, booking_datetime)
select 3, 1, ac.inventory_number, 'хорошее', current_timestamp
from available_copy ac
where ac.inventory_number is not null;
-- обновление статуса экземпляра на 'забронирована'
update public.book_instance 
set status = 'забронирована' 
where inventory_number in (
    select book_instance_number from public.booking 
    where reader_ticket_number = '3' 
    and book_id = 1
    and current_timestamp <= booking_datetime::date + interval '3 days'
);


-- задание 12: отмена бронирования
update public.book_instance 
set status = 'в наличии' 
where inventory_number in (
    select book_instance_number from public.booking 
    where reader_ticket_number = '3');

delete from public.booking 
where reader_ticket_number = '3';

-- задание 13: выдача с проверкой бронирования
insert into public.issuance (reader_ticket_number, book_instance_number, issue_datetime, expected_return_date)
select '3', 'inv-002', current_timestamp, current_date + interval '14 days'
where not exists (
    select 1 from public.booking b
    where b.book_instance_number = 'inv-002'
      and b.reader_ticket_number != '3'
      and current_timestamp <= b.booking_datetime::date + interval '3 days');
-- статус книги 'забронировано' -> 'выдана' 
update public.book_instance 
set status = 'выдана' 
where inventory_number = 'inv-002'
  and exists (
    select 1 from public.issuance 
    where reader_ticket_number = '3' 
      and book_instance_number = 'inv-002' 
      and actual_return_date is null);
-- удаление бронирования
delete from public.booking 
where book_instance_number = 'inv-002';

-- задание 14: поиск местоположений книги
create view public.book_locations_view as
select 
    b.id as book_id,
    b.title,
    a.last_name || ' ' || a.first_name as author_name,
    bi.inventory_number,
    bi.state as condition,
    (bi.section || ', ряд ' || bi.line || ', полка ' || bi.bookshelf) as location,
    case 
        when exists (select 1 from public.issuance i where i.book_instance_number = bi.inventory_number and i.actual_return_date is null) then 'выдан'
        when exists (select 1 from public.booking b where b.book_instance_number = bi.inventory_number and current_timestamp <= b.booking_datetime::date + interval '3 days') then 'забронирован'
        else 'доступен'
    end as availability_status
from public.book_instance bi
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
order by 
    case bi.state
        when 'отличное' then 1
        when 'хорошее' then 2
        when 'удовлетворительное' then 3
        when 'ветхое' then 4
        else 5
    end,
    bi.section, bi.line, bi.bookshelf;
--  использование представления
select * from public.book_locations_view where book_id = 1;

-- задание 15: доступные экземпляры
create view public.available_books_view as
select 
    b.id as book_id,
    b.title,
    a.last_name || ' ' || a.first_name as author_name,
    ph.name as publisher_name,
    bi.state as condition,
    count(bi.inventory_number) as available_count,
    string_agg(bi.inventory_number, ', ' order by 
        case bi.state
            when 'отличное' then 1
            when 'хорошее' then 2
            when 'удовлетворительное' then 3
            when 'ветхое' then 4
            else 5
        end
    ) as available_copies
from public.book_instance bi
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
join public.publishing_house ph on b.publishing_house_id = ph.id
where bi.status = 'в наличии' 
  and not exists (
      select 1 from public.issuance i 
      where i.book_instance_number = bi.inventory_number 
      and i.actual_return_date is null)
  and not exists (
      select 1 from public.booking bo 
      where bo.book_instance_number = bi.inventory_number
      and current_timestamp <= bo.booking_datetime::date + interval '3 days')
group by b.id, b.title, a.last_name, a.first_name, ph.name, bi.state
order by b.title, 
    case bi.state
        when 'отличное' then 1
        when 'хорошее' then 2
        when 'удовлетворительное' then 3
        when 'ветхое' then 4
        else 5
    end;
-- запрос для поиска книг определенного автора
select * from public.available_books_view 
where author_name ilike '%толстой%';
-- запрос для поиска книг в определённом состоянии
select * from public.available_books_view 
where condition = 'отличное';

-- задание 16: представление о не возвращённых книгах с выдачей более года назад
create view public.long_term_issues_view as
select 
    i.reader_ticket_number,
    r.last_name || ' ' || r.first_name as reader_name,
    b.title as book_title,
    a.last_name || ' ' || a.first_name as author_name,
    bi.inventory_number,
    i.issue_datetime,
    i.expected_return_date,
    (current_date - i.issue_datetime::date) as days_with_book,
    (current_date - i.expected_return_date) as days_overdue
from public.issuance i
join public.reader r on i.reader_ticket_number = r.ticket_number
join public.book_instance bi on i.book_instance_number = bi.inventory_number
join public.book b on bi.book_id = b.id
join public.author a on b.author_id = a.id
where i.actual_return_date is null 
  and (current_date - i.issue_datetime::date) > 365
order by days_with_book desc;
-- пример использования представления
select * from public.long_term_issues_view;

-- задание 17: таблица логов
create table if not exists public.logs (
    id serial primary key,
    log_date timestamp default current_timestamp,
    table_name varchar not null,
    log_content text not null);

-- задание 18: функция для триггеров
create or replace function log_dml_operations()
returns trigger as $$
declare
    v_log_content text;
begin
    --  содержимое лога в зависимости от типа операции
    if tg_op = 'INSERT' then
        v_log_content := 'добавлена запись: ' || row_to_json(new);
    elsif tg_op = 'UPDATE' then
        v_log_content := 'обновлена запись: было=' || row_to_json(old) || ', стало=' || row_to_json(new);
    elsif tg_op = 'DELETE' then
        v_log_content := 'удалена запись: ' || row_to_json(old);
    else
        v_log_content := 'неизвестная операция: ' || tg_op;
    end if;
    
    insert into public.logs (table_name, log_content)
    values (tg_table_name, v_log_content);
    
    -- возвращение соответствующей записи
    if tg_op = 'delete' then
        return old;
    else
        return new;
    end if;
end;
$$ language plpgsql;

-- триггер для таблицы author
create trigger trg_log_author
    after insert or update or delete on public.author
    for each row execute function log_dml_operations();

-- триггер для таблицы publishing_house
create trigger trg_log_publishing_house
    after insert or update or delete on public.publishing_house
    for each row execute function log_dml_operations();

-- триггер для таблицы book
create trigger trg_log_book
    after insert or update or delete on public.book
    for each row execute function log_dml_operations();

-- триггер для таблицы reader
create trigger trg_log_reader
    after insert or update or delete on public.reader
    for each row execute function log_dml_operations();

-- триггер для таблицы book_instance
create trigger trg_log_book_instance
    after insert or update or delete on public.book_instance
    for each row execute function log_dml_operations();

-- триггер для таблицы issuance
create trigger trg_log_issuance
    after insert or update or delete on public.issuance
    for each row execute function log_dml_operations();

-- триггер для таблицы booking
create trigger trg_log_booking
    after insert or update or delete on public.booking
    for each row execute function log_dml_operations();