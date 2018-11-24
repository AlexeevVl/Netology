--1.	Количество клиентов из sao Paulo оплативших заказ кредитной картой.
select count(*)
from olist_orders_dataset o inner join olist_order_customer_dataset c on o.customer_id=c.customer_id
inner join olist_order_payments_dataset p on o.order_id=p.order_id 
where customer_city='sao paulo' and payment_type='credit_card';
--2.	Среднее время доставки для каждого города по убыванию среднего времени (in days). 
select c.customer_city, avg(EXTRACT(EPOCH FROM (o.order_estimated_delivery_date-o.order_delivered_customer_date))/3600/24)
from olist_orders_dataset o inner join olist_order_customer_dataset c on o.customer_id=c.customer_id
group by c.customer_city
having avg(EXTRACT(EPOCH FROM (o.order_estimated_delivery_date-o.order_delivered_customer_date))/3600/24)<0
order by avg(EXTRACT(EPOCH FROM (o.order_estimated_delivery_date-o.order_delivered_customer_date))/3600/24) asc;
--3. Вывести итоговую сумму по каждому заказу.
select o.order_id,sum(i.price) as total_sum   
from olist_orders_dataset o inner join olist_order_items_dataset i on o.order_id=i.order_id
group by o.order_id;
--4. Вывести среднюю сумму заказа в городе клиента напротив полной суммы по заказу.
select o.order_id, t.total_sum, c.customer_city, avg(t.total_sum) over (PARTITION BY c.customer_city) as avg_city
from olist_orders_dataset o left join (select o.order_id,sum(i.price) as total_sum   
from olist_orders_dataset o inner join olist_order_items_dataset i on o.order_id=i.order_id
group by o.order_id) t on t.order_id=o.order_id
left join olist_order_customer_dataset c on o.customer_id=c.customer_id;
--5.	Какая средняя оценка на заказы в городе sao paulo по каждой категории продуктов.
select p.product_category_name, avg(r.review_score)
from olist_order_reviews_dataset r
left join olist_orders_dataset o on r.order_id=o.order_id
left join olist_order_customer_dataset c on o.customer_id=c.customer_id
left join olist_order_items_dataset i on o.order_id=i.order_id
left join olist_products_dataset p on i.product_id=p.product_id
where customer_city='sao paulo'
group by p.product_category_name;
--6.	Заказы с какой категорией продукта чаще всего отменяют. 
select p.product_category_name, count(o.order_id) as count_cancel
from olist_orders_dataset o inner join olist_order_items_dataset i on o.order_id=i.order_id
left join olist_products_dataset p on i.product_id=p.product_id
where o.order_status='canceled'
group by p.product_category_name
order by count(o.order_id) desc limit 1;
--7.	Найти три самых дорогих позиции в каждой категории продукта.
select distinct t.product_category_name,t.price  
from (select i.price, p.product_category_name, rank() OVER (partition by p.product_category_name order by i.price desc)  as ranking
from  olist_order_items_dataset i left join olist_products_dataset p on i.product_id=p.product_id) t
where t.ranking in (1,2,3);
--8.	Оценку за заказ с самой высокой платой за доставку.
select o.order_id, r.review_score
from olist_order_items_dataset i left join olist_orders_dataset o on i.order_id=o.order_id
left join olist_order_reviews_dataset r on  o.order_id=r.order_id
where i.freight_value=( 
select max(freight_value)
from olist_order_items_dataset);
--9.	Кол-во отзывов по каждой категории продуктов.
select p.product_category_name, count(*)
from olist_orders_dataset o left join olist_order_items_dataset i on i.order_id=o.order_id
left join olist_products_dataset p on i.product_id=p.product_id
left join olist_order_reviews_dataset r on  o.order_id=r.order_id
where p.product_category_name is not null
group by p.product_category_name;
--10.	Вывести топ-5 городов по заказам. 
select t1.customer_city,t1.number_clients
from
(select t.customer_city, t.number_clients, rank() over(order by number_clients desc) as ranking
from (select distinct c.customer_city, count(*) over (partition by c.customer_city) as number_clients
from olist_orders_dataset o inner join olist_order_customer_dataset c on o.customer_id=c.customer_id
order by number_clients desc) t) t1
where t1.ranking<=5;
















