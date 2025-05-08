# ANALIZA POPULARNOŚCI I ZAROBKÓW POSZCZEGÓŁNCYH SKLEPÓW SPRZEDAJĄCYCH ROWERY

-- używamy wcześniej przygotowaną scheme z gotowymi tabelami
use bike_store_;

-- sprawdzamy jej zawartość
show tables from bike_store_;

-- 1. Który sklep jest najpopularniejszy?
-- ile pracowników w każdym ze sklepów

drop table if exists staff_count;
create table staff_count as
select
	stores.store_id,
	stores.store_name,
    count(stores.store_name) as staff_count
from stores
inner join staffs
	on stores.store_id = staffs.store_id
group by stores.store_id, stores.store_name;


-- 2. Jaki produkt jest najpopularniejszy? 
drop table if exists items_sold;
create table items_sold as
select
	products.product_id,
	products.product_name,
    products.brand_id,
    order_items.item_id,
    order_items.order_id
from products
inner join order_items
	on products.product_id = order_items.product_id; 

select 
	orders.store_id,
    count(*) as store_popularity
from orders
left join staff_count
	on orders.store_id = staff_count.store_name
group by
	orders.store_id,
    staff_count.staff_count;
    

select 
	product_id,
    customer_id,
    store_id,
    list_price,
    quantity
from orders
left join order_items
	on orders.order_id = order_items.order_id;
    
-- Który klient dokonał największego zakupu i w jakim sklepie?
DROP TABLE IF EXISTS the_biggest_customer;
CREATE TABLE the_biggest_customer AS
SELECT
  oi.order_id,
  o.customer_id,
  ROUND( SUM(oi.list_price * (1 - oi.discount)), 2 ) AS total_price,
  o.store_id,
  o.staff_id
FROM order_items AS oi
RIGHT JOIN orders AS o
  ON o.order_id = oi.order_id
GROUP BY
  oi.order_id, o.customer_id, o.store_id, o.staff_id
ORDER BY
  total_price DESC;
  
-- Który ze sklepów najwięcej zarobił?
DROP TABLE IF EXISTS shops_earnings;
CREATE TABLE shops_earnings AS
select store_id,
	round(sum(total_price),2) as shop_earnings
from the_biggest_customer
group by the_biggest_customer.store_id
order by store_id desc;


-- Proporcja zarobków sklepu do ilości pracowników
-- z analizy widzimy, że sklep nr. 1 zarobił 3 razy mniej od sklepu nr.2
-- pomimo iż w sklepie nr.1 jest więcej pracowników
select 
	shops_earnings.store_id,
    shops_earnings.shop_earnings,
    staff_count.store_name,
    staff_count.staff_count,
	round((shops_earnings.shop_earnings / staff_count.staff_count),2) as earnings_per_staff
from shops_earnings
inner join staff_count
	on shops_earnings.store_id = staff_count.store_id
order by shop_earnings desc;

-- W jakich miesiącach oraz latach był największy przychód?
SELECT
  YEAR(order_date)  AS year,
  MONTH(order_date) AS month,
  round(SUM(total_price),2) AS revenue
FROM the_biggest_customer
inner join orders
	on the_biggest_customer.customer_id = orders.customer_id
GROUP BY
  YEAR(order_date),
  MONTH(order_date)
ORDER BY
	revenue desc;



  











