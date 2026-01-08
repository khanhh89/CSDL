 drop database if exists hackathon;
create database hackathon;
use hackathon;
create table if not exists Category(
	category_id varchar(10) primary key,
    category_name varchar(100) not null unique,
    description text
);
create table if not exists Product (
	product_id varchar(10) primary key,
    product_name varchar(150) not null,
    price decimal(10,2) not null,
    status varchar(50),
	category_id varchar(10) not null,
    foreign key (category_id) references Category(category_id)
);
create table if not exists `Order`(
	order_id int primary key auto_increment,
    order_date datetime not null,
	total_amount decimal(15,2) not null,
    customer_name varchar(100)
);
create table if not exists Order_detail(
	detail_id int primary key auto_increment,
    order_id int not null,
    product_id varchar(10) not null,
    quantity int not null,
    subtotal decimal(12,2),
    foreign key (order_id) references `Order` (order_id),
    foreign key (product_id) references Product(product_id)
);
-- chèn dữ liệu 
-- Category
insert into Category values
('C01','Coffee','All types of coffee beans and brews'),
('C02','Tea & Fruit','Fresh fruit juices and tea'),
('C03','Bakery','Cakes and pastries');
-- Product
insert into Product values
('P001','Espresso',35000,'Available','C01'),
('P002','Matcha Latte',45000,'Available','C02'),
('P003','Tiramisu',55000,'Available','C03'),
('P004','Cold Brew',50000,'Out of Stock','C01'),
('P005','Croissant',30000,'Available','C03');
-- Order
insert into `Order` (order_id, order_date, total_amount, customer_name) values
(1,'2025-01-01 08:30:00',80000,'Mr. An'),
(2,'2025-01-01 09:15:00',45000,'Ms. Hoa'),
(3,'2025-01-02 14:00:00',140000,'Mr. Binh'),
(4,'2025-01-03 10:00:00',35000,'Anonymous'),
(5,'2025-01-03 11:20:00',90000,'Ms. Lan');
-- Order_detail
insert into Order_detail (order_id, product_id, quantity, subtotal) values
(1,'P001',1,35000),
(1,'P002',1,45000),
(3,'P002',2,90000),
(3,'P005',1,50000),
(5,'P002',2,90000);
-- truy vấn dữ liệu cơ bản
-- đổi trạng thái Cold brew sang ....
 update Product set status = 'Available' where product_name = 'Cold Brew';
-- tăng 10% cho tất cả các sản phẩm thuộc danh mục 'Bakeyry'
update Product set price = price * 1.10 where category_id = 'C03';
-- 	xóa  chi tiết đơn hàng có số lượng  bằng 0 hoặc nhỏ hơn
 delete from Order_detail where quantity <= 0;
-- của các sản phẩm có giá từ 40,000 trở lên và đang còn hàng
select product_id, product_name, price from Product where price >= 40000 and status = 'Available';
-- Lấy thông tin của khách hàng cs tên bắt đầu là M
select order_id, order_date, customer_name from `Order` where customer_name like 'M%';
-- hiện danh sách sản phẩm
select product_name, price from Product order by price desc;
-- lấy 3 đơn hàng mới nhất
select * from `Order` order by order_date desc limit 3;
-- Hiển thị danh sách sản phẩm, bỏ qua 2 sản phẩm đầu tiên và lấy 3 sản phẩm tiếp theo
select * from Product limit 3 offset 2;

-- TRUY VẤN NÂNG CAO
-- hiển thị tên và danh mục của từng sản phẩm
select p.product_name, p.price, c.category_name from Product p
join Category c on p.category_id = c.category_id;

-- Liệt kê tất cả danh mục và các sản phẩm thuộc danh mục đó. Hiển thị cả những danh mục chưa có sản phẩm nào
select c.category_name, p.product_name from Category c
left join Product p on c.category_id = p.category_id;

-- Tính tổng doanh thu của quán theo từng ngày
select date (order_date) as order_day,
       sum(total_amount) as total_revenue from `Order` 
       group by date (order_date);
       
-- Thống kê những đơn hàng (order_id) có từ 2 loại sản phẩm khác nhau trở lên trong order_detail      
select order_id from Order_detail
		group by order_id
		having count(distinct product_id) >= 2;
        
-- 15 Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm trong quán.
select product_name, price from Product 
where price > (select avg(price) from Product);

-- 16 Hiển thị tên các khách hàng đã từng mua sản phẩm 'Matcha Latte
select distinct o.customer_name
from `Order` o join Order_detail od on o.order_id = od.order_id
join Product p on od.product_id = p.product_id
where p.product_name = 'Matcha Latte';

-- 17 Hiển thị bảng thông tin về đơn hàng gồm: order_id, order_date, product_name, quantity, subtotal
select o.order_id, o.order_date, p.product_name, od.quantity, od.subtotal
from `Order` o
join Order_detail od on o.order_id = od.order_id
join Product p on od.product_id = p.product_id;