/*
=============================================
DATABASE: StudentManagement
SESSION 15 - FULL EXAM SOLUTION
=============================================
*/

-- =========================
-- 0. DATABASE
-- =========================
drop database if exists studentmanagement;
create database studentmanagement;
use studentmanagement;

-- =========================
-- 1. TABLE STRUCTURE
-- =========================

-- Students
create table students (
    studentid char(5) primary key,
    fullname varchar(50) not null,
    totaldebt decimal(10,2) default 0
);

-- Subjects
create table subjects (
    subjectid char(5) primary key,
    subjectname varchar(50) not null,
    credits int check (credits > 0)
);

-- Grades
create table grades (
    studentid char(5),
    subjectid char(5),
    score decimal(4,2) check (score between 0 and 10),
    primary key (studentid, subjectid),
    foreign key (studentid) references students(studentid),
    foreign key (subjectid) references subjects(subjectid)
);

-- GradeLog
create table gradelog (
    logid int auto_increment primary key,
    studentid char(5),
    oldscore decimal(4,2),
    newscore decimal(4,2),
    changedate datetime default current_timestamp
);

-- =========================
-- 2. SEED DATA
-- =========================

insert into students values
('SV01', 'Ho Khanh Linh', 5000000),
('SV03', 'Tran Thi Khanh Huyen', 0);

insert into subjects values
('SB01', 'Co so du lieu', 3),
('SB02', 'Lap trinh Java', 4),
('SB03', 'Lap trinh C', 3);

insert into grades values
('SV01', 'SB01', 8.5),
('SV03', 'SB02', 3.0);
-- Câu 1: Trigger kiểm tra điểm hợp lệ
delimiter //
create trigger tg_checkscore
before insert on grades
for each row
begin
    if new.score < 0 then set new.score = 0;
    elseif new.score > 10 then set new.score = 10;
    end if;
end//
delimiter ;
-- Câu 2: Transaction thêm sinh viên
start transaction;
insert into students (studentid, fullname)
values ('SV02', 'Ha Bich Ngoc');
update students set totaldebt = 5000000 where studentid = 'SV02';
commit;
-- Câu 3: Trigger ghi log khi cập nhật điểm
delimiter //
create trigger tg_loggradeupdate
after update on grades
for each row
begin
    if old.score <> new.score then
        insert into gradelog (studentid, oldscore, newscore, changedate)
        values (old.studentid, old.score, new.score, now());
    end if;
end//
delimiter ;
-- Câu 4: Stored Procedure đóng học phí
delimiter //
create procedure sp_paytuition()
begin
    start transaction;
    update students
    set totaldebt = totaldebt - 2000000
    where studentid = 'SV01';
    if (select totaldebt from students where studentid = 'SV01') < 0 then
        rollback;
    else
        commit;
    end if;
end//
-- Câu 5: Trigger không cho sửa điểm đã qua môn
delimiter //
create trigger tg_preventpassupdate
before update on grades
for each row
begin
    if old.score >= 4.0 then
        signal sqlstate '45000'
        set message_text = 'Khong duoc sua diem da qua mon';
    end if;
end//
delimiter ;
-- Câu 6: Stored Procedure xóa điểm sinh viên
delimiter //
create procedure sp_deletestudentgrade(
    in p_studentid char(5),
    in p_subjectid char(5)
)
begin
    start transaction;
    insert into gradelog (studentid, oldscore, newscore, changedate)
    select p_studentid, score, null, now()
    from grades
    where studentid = p_studentid
      and subjectid = p_subjectid;
    delete from grades
    where studentid = p_studentid
      and subjectid = p_subjectid;
    if row_count() = 0 then
        rollback;
    else
        commit;
    end if;
end//
delimiter ;