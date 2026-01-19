drop database if exists session16;
create database session16;
use session16;
create table customers (
  customer_id int auto_increment primary key,
  customer_name varchar(100) not null,
  phone varchar(20) not null unique,
  address varchar(255),
  email varchar(100) not null unique
);
create table products (
  product_id int auto_increment primary key,
  product_name varchar(100) not null unique,
  price decimal(10,2) not null,
  quantity int not null check (quantity >= 0),
  category varchar(50) not null
);
create table employees (
  employee_id int auto_increment primary key,
  employee_name varchar(100) not null,
  position varchar(50) not null,
  salary decimal(10,2) not null,
  revenue decimal(10,2) default 0
);

create table orders (
  order_id int auto_increment primary key,
  customer_id int,
  employee_id int,
  order_date datetime default current_timestamp,
  total_amount decimal(10,2) default 0,
  foreign key (customer_id) references customers(customer_id),
  foreign key (employee_id) references employees(employee_id)
);
create table order_details (
  order_detail_id int auto_increment primary key,
  order_id int,
  product_id int,
  quantity int not null check (quantity > 0),
  unit_price decimal(10,2) not null,
  foreign key (order_id) references orders(order_id),
  foreign key (product_id) references products(product_id)
);
insert into customers (customer_name, phone, address, email) values
('khách 1','0123456789','địa chỉ 1','k1@gmail.com'),
('khách 2','0987654321','địa chỉ 2','k2@gmail.com');
insert into employees (employee_name, position, salary) values
('nhân viên 1','bán hàng',8000000),
('nhân viên 2','bán hàng',9000000);
insert into products (product_name, price, quantity, category) values
('laptop dell xps',2000,200,'laptop'),
('chuột logitech',50,500,'phụ kiện');
insert into orders (customer_id, employee_id, order_date) values
(1,1,'2025-01-01'),
(2,2,'2025-01-02');
update products
set product_name = 'laptop dell xps 13', price = 1999.99
where product_id = 1;

select o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
from orders o
join customers c on o.customer_id = c.customer_id
join employees e on o.employee_id = e.employee_id;
select c.customer_id, c.customer_name, count(o.order_id) as total_order
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

select e.employee_id, e.employee_name, sum(o.total_amount) as total_revenue
from employees e
join orders o on e.employee_id = o.employee_id
where year(o.order_date) = year(curdate())
group by e.employee_id, e.employee_name;
select c.customer_id, c.customer_name
from customers c
where c.customer_id not in (select customer_id from orders);
select product_id, product_name
from products
where price > (select avg(price) from products);
select c.customer_id, c.customer_name, sum(o.total_amount) as total_spend
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having sum(o.total_amount) = (
  select max(t.total_spend)
  from (
    select sum(total_amount) as total_spend
    from orders
    group by customer_id
  ) t
);
create view view_order_list as
select o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
from orders o
join customers c on o.customer_id = c.customer_id
join employees e on o.employee_id = e.employee_id;
create view view_order_detail_product as
select od.order_detail_id, p.product_name, od.quantity, od.unit_price
from order_details od
join products p on od.product_id = p.product_id;
delimiter $$
create procedure proc_insert_employee(
  in p_name varchar(100),
  in p_position varchar(50),
  in p_salary decimal(10,2)
)
begin
  insert into employees(employee_name, position, salary)
  values (p_name, p_position, p_salary);
end$$
create procedure proc_get_orderdetails(in p_order_id int)
begin
  select * from order_details where order_id = p_order_id;
end$$
create procedure proc_cal_total_amount_by_order(in p_order_id int)
begin
  select sum(quantity * unit_price) as total_amount
  from order_details
  where order_id = p_order_id;
end$$
delimiter ;
delimiter $$
create trigger trg_before_insert_order_details
before insert on order_details
for each row
begin
  declare stock int;
  select quantity into stock
  from products
  where product_id = new.product_id;
  if stock < new.quantity then
    set new.quantity = 0;
  else
    update products
    set quantity = quantity - new.quantity
    where product_id = new.product_id;
  end if;
end$$
delimiter ;
delimiter $$

create procedure proc_insert_order_details (
  in p_order_id int,
  in p_product_id int,
  in p_quantity int,
  in p_unit_price decimal(10,2)
)
begin
  declare v_count int default 0;

  start transaction;

  -- kiểm tra mã hóa đơn có tồn tại hay không
  select count(*) into v_count
  from orders
  where order_id = p_order_id;

  if v_count = 0 then
    rollback;
    signal sqlstate '45000'
      set message_text = 'không tồn tại mã hóa đơn';
  end if;

  -- chèn chi tiết đơn hàng
  insert into order_details (order_id, product_id, quantity, unit_price)
  values (p_order_id, p_product_id, p_quantity, p_unit_price);

  -- cập nhật tổng tiền đơn hàng
  update orders
  set total_amount = total_amount + (p_quantity * p_unit_price)
  where order_id = p_order_id;
  commit;
end$$
delimiter ;
-- trường hợp đúng
call proc_insert_order_details(1, 1, 2, 100);
-- trường hợp sai (không tồn tại hóa đơn)
call proc_insert_order_details(999, 1, 2, 100);
