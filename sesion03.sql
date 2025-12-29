drop database if exists sesion03;
create database  sesion03;
use sesion03;

create table if not exists student (
    student_id int primary key,
    full_name varchar(100) not null,
    date_of_birth date,
    email varchar(150) unique
);
create table if not exists subject (
    subject_id int primary key,
    subject_name varchar(100) not null,
    credit int not null check (credit > 0)
);
create table if not exists enrollment (
    enroll_id int primary key auto_increment,
    student_id int,
    subject_id int,
    enroll_date date,
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id),
    unique (student_id, subject_id)
);

create table if not exists score (
    student_id int,
    subject_id int,
    mid_score float check (mid_score between 0 and 10),
    final_score float check (final_score between 0 and 10),
    primary key (student_id, subject_id),
    foreign key (student_id) references student(student_id),
    foreign key (subject_id) references subject(subject_id)
);
insert into student values
(1, 'Đào Xuân Khánh', '2002-05-10', 'khanh@gmail.com'),
(2, 'Trần Thị K', '2001-12-22', 'b@.com'),
(3, 'Lê Hoàng C', '2003-02-15', 'c@.com');

insert into subject values
(101, 'Cơ sở dữ liệu', 3),
(102, 'lập trình java', 4),
(103, 'toán rời rạc nâng cao', 3);
insert into enrollment (student_id, subject_id, enroll_date)
values
(1, 101, '2025-01-10'),
(1, 102, '2025-01-11'),
(2, 101, '2025-01-12'),
(3, 103, '2025-01-12');

insert into score (student_id, subject_id, mid_score, final_score)
values
(1, 101, 7.5, 8.0),
(1, 102, 6.0, 7.0),
(2, 101, 5.0, 6.5),
(3, 103, 8.5, 9.0);

update student
set email = 'new_email_3@example.com'
where student_id = 3;

update student
set date_of_birth = '2001-05-02'
where student_id = 2;
delete from student
where student_id = 5;
update subject
set credit = 5
where subject_id = 102;

update subject
set subject_name = 'toán rời rạc nâng cao'
where subject_id = 103;

insert into student values
(10, 'Nguyễn Văn D', '2004-09-12', 'vand@example.com');

insert into enrollment (student_id, subject_id, enroll_date)
values
(10, 101, '2025-01-05'),
(10, 102, '2025-01-06'),
(10, 103, '2025-01-06');
insert into score (student_id, subject_id, mid_score, final_score)
values
(10, 101, 6.5, 7.0),
(10, 102, 8.0, 8.5);

update score
set final_score = 9.0
where student_id = 10 and subject_id = 102;
delete from enrollment
where student_id = 10 and subject_id = 103;
select * from student;
select * from subject;
select * from enrollment;
select * from score;