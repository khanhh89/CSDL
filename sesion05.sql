drop database if exists thuongmaidientu;
create database if not exists thuongmaidientu;
use thuongmaidientu;

create table if not exists products (
    product_id int auto_increment,
    product_name varchar(255),
    price decimal(10,2),
    stock int,
    status enum('active','inactive'),
    primary key (product_id)
);
alter table products add column sold_quantity int;
insert into products (product_name, price, stock, status) values
('điện thoại samsung', 8500000, 10, 'active'),
('laptop dell', 15500000, 5, 'active'),
('ốp lưng điện thoại', 50000, 100, 'inactive'),
('điện thoại samsung', 8500000, 10, 'active'),
('laptop dell', 15500000, 5, 'active'),
('ốp lưng điện thoại', 50000, 100, 'inactive'),
('điện thoại samsung', 8500000, 10, 'active'),
('laptop dell', 15500000, 5, 'active'),
('ốp lưng điện thoại', 50000, 100, 'inactive');

-- select * from products;
-- select * from products where status = 'active';
-- select * from products where price > 5000000;
-- select * from products order by price;
select * from products order by sold_quantity desc limit 10;
select * from products order by sold_quantity desc limit 5 offset 10;
select * from products where price < 2000000 order by sold_quantity desc;
select * from products where status = 'active' and price between 1000000 and 3000000 order by price asc limit 10 offset 0;
select * from products where status = 'active'and price between 1000000 and 3000000 order by price asc limit 10 offset 10;

drop database if exists baitap2;
create database baitap2;
use baitap2;
create table if not exists customers (
    customer_id int auto_increment,
    full_name varchar(255),
    email varchar(255),
    city varchar(255),
    status enum('active','inactive'),
    primary key (customer_id)
);
insert into customers (full_name, email, city, status) values
('đào xuân khánh', 'khanh@gmail.com', 'hà nội', 'active'),
('nguyễn văn a', 'vana@gmail.com', 'hà nội', 'active'),
('trần thị b', 'thib@gmail.com', 'hồ chí minh', 'inactive'),
('lê văn c', 'vanc@gmail.com', 'hồ chí minh', 'active');

-- select * from customers;
-- select * from customers where city = 'hồ chí minh';
-- select * from customers where status = 'active' and city = 'hà nội'order by full_name;

drop database if exists baitap3;
create database baitap3;
use baitap3;
create table if not exists orders (
    order_id int auto_increment,
    customer_id int,
    total_amount decimal(10,2),
    order_date date,
    status enum('pending', 'completed', 'cancelled'),
    primary key (order_id)
);
insert into orders (customer_id, total_amount, order_date, status) values
(1, 8000000, curdate(), 'completed'),
(2, 3000000, curdate(), 'pending'),
(3, 12000000, curdate(), 'completed'),
(4, 20000000, curdate(), 'completed'),
(5, 2000000, curdate(), 'completed'),
(6, 5500000, curdate(), 'completed'),
(7, 5000000, curdate(), 'completed'),
(8, 3330000, curdate(), 'completed');
-- select * from orders where status = 'completed';
-- select * from orders where total_amount > '8000000';
-- select * from orders order by order_date limit 5; 
-- select * from orders where status = 'completed' order by total_amount desc;
select * from orders where status <> 'cancelled' order by order_date desc limit 5 offset 0;
select * from orders where status <> 'cancelled' order by order_date desc limit 5 offset 5;
select * from orders where status <> 'cancelled' order by order_date desc limit 5 offset 10;