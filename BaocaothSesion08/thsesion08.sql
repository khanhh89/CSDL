create database miniprj;
use miniprj;

drop table if exists order_items;
drop table if exists orders;
drop table if exists products;
drop table if exists categories;
drop table if exists customers;

create table customers (
  customer_id int primary key auto_increment,
  customer_name varchar(100) not null,
  email varchar(100) not null unique,
  phone varchar(10) not null unique
);

create table categories (
  category_id int primary key auto_increment,
  category_name varchar(255) not null unique
);

create table products (
  product_id int primary key auto_increment,
  product_name varchar(255) not null unique,
  price decimal(10,2) not null check (price > 0),
  category_id int not null,
  foreign key (category_id) references categories(category_id)
);

create table orders (
  order_id int primary key auto_increment,
  customer_id int not null,
  order_date datetime default now(),
  status enum('pending','completed','cancel') default 'pending',
  foreign key (customer_id) references customers(customer_id)
);

create table order_items (
  order_item_id int primary key auto_increment,
  order_id int not null,
  product_id int not null,
  quantity int not null check (quantity > 0),
  foreign key (order_id) references orders(order_id),
  foreign key (product_id) references products(product_id)
);

insert into customers (customer_name, email, phone) values
('nguyễn văn an', 'an.nguyen@example.com', '0900000001'),
('trần thị bình', 'binh.tran@example.com', '0900000002'),
('lê quốc cường', 'cuong.le@example.com', '0900000003'),
('phạm minh duy', 'duy.pham@example.com', '0900000004'),
('võ thị hạnh', 'hanh.vo@example.com', '0900000005'),
('đặng gia khang', 'khang.dang@example.com', '0900000006'),
('hoàng mai lan', 'lan.hoang@example.com', '0900000007');

insert into categories (category_name) values
('điện thoại'),
('laptop'),
('phụ kiện'),
('tai nghe'),
('đồng hồ thông minh'),
('màn hình'),
('thiết bị mạng');

insert into products (product_name, price, category_id) values
('iphone 14 128gb', 18990000.00, 1),
('samsung galaxy s23', 16990000.00, 1),
('macbook air m2 13"', 25990000.00, 2),
('chuột logitech m331', 399000.00, 3),
('tai nghe sony wh-1000xm5', 6990000.00, 4),
('apple watch se 40mm', 5990000.00, 5),
('router tp-link archer c6', 690000.00, 7);

insert into orders (customer_id, order_date, status) values
(1, '2026-01-01 09:10:00', 'pending'),
(2, '2026-01-02 14:25:00', 'completed'),
(1, '2026-01-03 10:05:00', 'completed'),
(4, '2026-01-03 16:40:00', 'cancel'),
(5, '2026-01-04 11:15:00', 'pending'),
(6, '2026-01-05 19:30:00', 'completed'),
(6, '2026-01-06 08:50:00', 'pending');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(2, 4, 2),
(1, 3, 1),
(4, 2, 1),
(5, 7, 1),
(6, 5, 1),
(7, 6, 1);

select * from categories;

select * from orders
where status = 'completed';

select * from products
order by price desc;

select * from products
order by price desc
limit 5 offset 2;

select p.product_id, p.product_name, p.price, c.category_name
from products p
left join categories c
on p.category_id = c.category_id;

select o.order_id, o.order_date, c.customer_name, o.status
from orders o
left join customers c
on o.customer_id = c.customer_id;

select oi.order_item_id, p.product_name, sum(oi.quantity) as so_luong
from order_items oi
left join products p
on p.product_id = oi.product_id
group by oi.order_item_id, p.product_name;

select c.customer_id, c.customer_name, count(o.order_id) as so_don_hang
from customers c
left join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

select c.customer_id, c.customer_name, count(o.order_id) as total_orders
from customers c
join orders o
on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(o.order_id) >= 2;

select c.category_id, c.category_name,
       avg(p.price) as avg_price,
       min(p.price) as min_price,
       max(p.price) as max_price
from categories c
left join products p
on c.category_id = p.category_id
group by c.category_id, c.category_name
order by c.category_id asc;

select product_id, product_name, price
from products
where price > (
  select avg(price)
  from products
);

select *
from customers
where customer_id in (
  select customer_id
  from orders
);

select *
from orders
where order_id in (
  select order_id
  from order_items
  group by order_id
  order by sum(quantity) desc
  limit 1
);

select cus.customer_name
from customers cus
join orders o on cus.customer_id = o.customer_id
join order_items oi on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
where p.category_id = (
  select category_id
  from (
    select c.category_id, avg(p.price) as avg_price
    from categories c
    join products p
    on c.category_id = p.category_id
    group by c.category_id
    order by avg_price desc
    limit 1
  ) as sub
);

select c.customer_id, c.customer_name, sum(t.quantity) as total_products
from (
  select o.customer_id, oi.quantity
  from orders o
  join order_items oi
  on o.order_id = oi.order_id
) as t
join customers c
on t.customer_id = c.customer_id
group by c.customer_id, c.customer_name;

select *
from products
where price = (
  select max(price)
  from products
);
