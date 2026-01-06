drop database if exists session07;
create database session07;
use session07;
create table customers (
    id int primary key,
    name varchar(100),
    email varchar(100)
);
create table orders (
    id int primary key,
    customer_id int,
    order_date date,
    total_amount decimal(10,2)
);
insert into customers values
(1, 'an', 'an@gmail.com'),
(2, 'binh', 'binh@gmail.com'),
(3, 'chi', 'chi@gmail.com'),
(4, 'dung', 'dung@gmail.com'),
(5, 'hoa', 'hoa@gmail.com'),
(6, 'khanh', 'khanh@gmail.com'),
(7, 'linh', 'linh@gmail.com');
insert into orders values
(1, 1, '2024-06-01', 500000),
(2, 1, '2024-06-10', 1200000),
(3, 2, '2024-06-05', 750000),
(4, 3, '2024-06-07', 300000),
(5, 3, '2024-06-20', 950000),
(6, 5, '2024-06-15', 400000),
(7, 6, '2024-06-18', 1100000);
select id, name, email
from customers
where id in (
    select customer_id
    from orders
);
create table products (
    id int primary key,
    name varchar(100),
    price decimal(10,2)
);
create table order_items (
    order_id int,
    product_id int,
    quantity int
);
insert into products values
(1, 'laptop', 15000000),
(2, 'chuot', 300000),
(3, 'ban phim', 500000),
(4, 'tai nghe', 700000),
(5, 'man hinh', 4000000),
(6, 'usb', 200000),
(7, 'o cung', 2500000);
insert into order_items values
(1, 1, 2),
(1, 2, 1),
(2, 3, 1),
(2, 4, 2),
(3, 1, 1),
(3, 5, 1),
(4, 6, 3);

select id, name, price
from products
where id in (
    select product_id
    from order_items
);
insert into orders values
(8, 2, '2024-07-01', 2000000),
(9, 4, '2024-07-02', 150000),
(10, 5, '2024-07-03', 800000),
(11, 6, '2024-07-04', 3000000),
(12, 1, '2024-07-05', 950000);
select id, customer_id, order_date, total_amount
from orders
where total_amount > (
    select avg(total_amount)
    from orders
);
select
    name,
    (
        select count(*)
        from orders
        where orders.customer_id = customers.id
    ) as total_orders
from customers;
select id, name, email
from customers
where id = (
    select customer_id
    from orders
    group by customer_id
    having sum(total_amount) = (
        select max(total_spent)
        from (
            select sum(total_amount) as total_spent
            from orders
            group by customer_id
        ) as t
    )
);
select customer_id, sum(total_amount) as total_spent
from orders
group by customer_id
having sum(total_amount) > (
    select avg(customer_total)
    from (
        select sum(total_amount) as customer_total
        from orders
        group by customer_id
    ) as t
);