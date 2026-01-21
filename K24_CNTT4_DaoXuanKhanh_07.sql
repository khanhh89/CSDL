create database final;
use final;
-- patients 
create table patients (
    patient_id int auto_increment primary key,
    full_name varchar(100) not null,
    phone_number varchar(15) unique,
    gender enum('male','female') not null,
    date_of_birth date not null,
    check (date_of_birth < '2025-01-01')
);
-- doctors 
create table doctors (
    doctor_id int auto_increment primary key,
    full_name varchar(100) not null,
    specialty varchar(50) not null,
    phone_number varchar(15) unique,
    rating decimal(2,1) default 5.0,
    check (rating between 0 and 5)
);
-- appointments 
create table appointments (
    appointment_id int auto_increment primary key,
    patient_id int not null,
    doctor_id int not null,
    appointment_time datetime not null,
    fee decimal(10,2) check (fee > 0),
    status enum('booked','completed','cancelled') not null,
    foreign key (patient_id) references patients(patient_id),
    foreign key (doctor_id) references doctors(doctor_id)
);
-- medical records 
create table medical_records (
    record_id int auto_increment primary key,
    appointment_id int not null unique,
    diagnosis varchar(255),
    treatment varchar(255),
    foreign key (appointment_id) references appointments(appointment_id)
);
-- visit log 
create table visit_log (
    log_id int auto_increment primary key,
    record_id int not null,
    doctor_id int not null,
    log_time datetime not null,
    note varchar(255),
    foreign key (record_id) references medical_records(record_id),
    foreign key (doctor_id) references doctors(doctor_id)
);
-- insert data 
insert into patients values
(1,'nguyen thi lan','0901234567','female','1999-05-10'),
(2,'tran van minh','0902345678','male','1998-08-15'),
(3,'le hoai phuong','0913456789','female','2001-03-20'),
(4,'pham minh duc','0924567890','male','1997-11-02'),
(5,'hoang quoc viet','0905678901','male','1996-06-18');
insert into doctors values
(1,'dr le van hung','noi','0981111111',4.8),
(2,'dr tran thi mai','nhi','0982222222',4.9),
(3,'dr pham quang minh','tim mach','0983333333',4.6),
(4,'dr nguyen thu ha','da lieu','0984444444',5.0),
(5,'dr doan van long','nhi','0985555555',4.7);
insert into appointments values
(1001,1,1,'2024-05-18 08:00',300000,'completed'),
(1002,2,2,'2024-05-19 09:00',250000,'completed'),
(1003,3,3,'2024-05-20 10:00',400000,'booked'),
(1004,4,4,'2024-05-21 14:00',350000,'completed'),
(1005,5,5,'2024-05-22 15:00',200000,'cancelled');
insert into medical_records values
(201,1001,'cam cum','uong thuoc'),
(202,1002,'viem hong','khang sinh'),
(203,1003,'kiem tra tim','theo doi'),
(204,1004,'di ung da','thuoc boi'),
(205,1005,'huy hen','khong kham');
insert into visit_log values
(1,201,1,'2024-05-18 09:00','visit'),
(2,202,2,'2024-05-19 10:00','visit'),
(3,203,3,'2024-05-20 11:00','consult'),
(4,204,4,'2024-05-21 15:00','revisit'),
(5,205,5,'2024-05-22 16:00','cancel');
-- update & delete 
set sql_safe_updates = 0;
update appointments a join patients p on a.patient_id = p.patient_id
set a.fee = a.fee * 1.1 where a.status = 'completed'and year(p.date_of_birth) < 2000 and a.appointment_id is not null;
delete from visit_log where log_time < '2024-05-20' and log_id is not null;
set sql_safe_updates = 1;
-- basic select 
select full_name, specialty, rating
from doctors
where rating > 4.7 or specialty = 'nhi';
select full_name, phone_number from patients where date_of_birth between '1998-01-01' and '2001-12-31' and phone_number like '090%';
select appointment_id, appointment_time, fee
from appointments order by fee desc limit 2 offset 2;
-- advanced select 
select p.full_name patient_name, d.full_name doctor_name, d.specialty, a.fee, a.appointment_time from appointments a
join patients p on a.patient_id = p.patient_id
join doctors d on a.doctor_id = d.doctor_id;
select d.full_name, sum(a.fee) total_fee
from doctors d
join appointments a on d.doctor_id = a.doctor_id
where a.status = 'completed'
group by d.doctor_id
having total_fee > 500000;
select doctor_id, full_name, rating from doctors where rating = (select max(rating) from doctors);
-- index & view 
create index idx_appointment_status_fee
on appointments(status, fee);
create view vw_doctor_revenue as
select d.full_name, count(a.appointment_id) total_appointments, sum(a.fee) total_revenue
from doctors d left join appointments a on d.doctor_id = a.doctor_id and a.status <> 'cancelled' group by d.doctor_id;
-- trigger 
delimiter $$
create trigger trg_after_completed
after update on appointments
for each row
begin
	if new.status = 'completed' and old.status <> 'completed' then
        insert into visit_log(record_id, doctor_id, log_time, note)
        values ((select record_id from medical_records where appointment_id = new.appointment_id),new.doctor_id,now(),'visit completed');
    end if;
end$$