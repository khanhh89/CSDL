drop database if exists thuongmaidientu;
create database if not exists thuongmaidientu;
use thuongmaidientu;
create table if not exists customers (
    customer_id int auto_increment primary key,
    fullname varchar(255),
    city varchar(255)
);
create table if not exists orders (
    order_id int auto_increment primary key,
    customer_id int,
    order_date date,
    status enum('pending','completed','cancelled'),
    total_amount decimal(10,2),
    foreign key (customer_id) references customers(customer_id)
);
create table if not exists products (
    product_id int auto_increment primary key,
    product_name varchar(255),
    price decimal(10,2)
);
create table if not exists order_items (
    order_id int,
    product_id int,
    quantity int,
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);
insert into customers (fullname,city) values('khanh dao','hưng yên'),('khanh 2','hưng yên 1'),('khanh 3','hưng yên 0'),('khanh 4','hưng yên no1'),('khanh 5','hưng yên 44');
insert into orders (customer_id,order_date,status,total_amount) values(1,'2025-01-10','completed',3500000),(1,'2025-01-15','completed',4200000),(1,'2025-01-18','completed',2800000),(2,'2025-01-20','completed',2300000),(3,'2025-01-25','cancelled',500000),(4,'2025-02-01','completed',3200000),(4,'2025-02-05','completed',4000000),(4,'2025-02-10','completed',3500000);
insert into products (product_name,price) values('chuot logitech',500000),('ban phim co',1500000),('man hinh 24 inch',3500000),('tai nghe gaming',1200000),('laptop acer',15000000);
insert into order_items values(1,1,2),(1,2,1),(2,3,1),(3,1,3),(3,4,2),(4,2,2),(5,5,1),(6,3,1),(7,2,2),(8,4,3),(8,1,4),(7,1,2),(6,2,3); select o.order_id,c.fullname, o.order_date,o.status,o.total_amount from orders o join customers c on o.customer_id=c.customer_id;
select c.customer_id, c.fullname, count(o.order_id) as total_orders from customers c left join orders o on c.customer_id=o.customer_id group by c.customer_id,c.fullname;
select c.customer_id, c.fullname, sum(o.total_amount) as tong_tien from customers c join orders o on c.customer_id=o.customer_id group by c.customer_id,c.fullname order by tong_tien desc;
select order_date, sum(total_amount) as tong_doanh_thu, count(order_id) as so_don_hang from orders where status='completed' group by order_date having sum(total_amount)>10000000;
select p.product_id, p.product_name, sum(oi.quantity) as so_luong_da_ban from products p join order_items oi on p.product_id=oi.product_id group by p.product_id,p.product_name;
select p.product_id, p.product_name, sum(oi.quantity * p.price) as doanh_thu from products p join order_items oi on p.product_id=oi.product_id group by p.product_id,p.product_name;
select
    p.product_id,
    p.product_name,
    sum(oi.quantity * p.price) as doanh_thu
from products p
join order_items oi on p.product_id=oi.product_id
group by p.product_id,p.product_name
having sum(oi.quantity * p.price) > 5000000;

select
    c.customer_id,
    c.fullname,
    count(o.order_id) as tong_so_don,
    sum(o.total_amount) as tong_tien,
    avg(o.total_amount) as gia_tri_don_trung_binh
from customers c
join orders o on c.customer_id=o.customer_id
group by c.customer_id,c.fullname
having count(o.order_id) >= 3
   and sum(o.total_amount) > 10000000
order by tong_tien desc;
select p.product_name,
sum(oi.quantity) as tong_so_luong_ban,
sum(oi.quantity * p.price) as tong_doanh_thu,
avg(p.price) as gia_ban_trung_binh from products p join order_items oi on p.product_id=oi.product_id
group by p.product_id,p.product_name having sum(oi.quantity) >= 10
order by tong_doanh_thu desc limit 5;
select * from customers;
select * from orders;
select * from products;
select * from order_items;