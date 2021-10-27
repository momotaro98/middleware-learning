-- 欲しいデータ
-- 特定の期間にてレンタルしたカスタマーでカスタマーIDが若い順の上位5人分のみのレンタルトランザクションを表示したい

-- -- クエリ1
-- select rental.rental_id, rental.rental_date, rental.customer_id
-- from sakila.rental rental
-- inner join (
--  select c.customer_id from sakila.customer c
--   join sakila.rental r on c.customer_id = r.customer_id
--   where r.rental_date between '2005-05-28 00:00:00' and '2005-06-03 00:00:00'
--   group by c.customer_id
--   order by c.customer_id asc
--   limit 5
-- ) top_n_c
-- on rental.customer_id = top_n_c.customer_id
-- where rental.rental_date between '2005-05-28 00:00:00' and '2005-06-03 00:00:00'
-- order by rental.customer_id, rental.rental_date asc

--  -- クエリ2
-- select rental_id, rental_date, customer_id
-- FROM (
-- 	SELECT 
--     r.rental_id,
-- 	r.rental_date,
-- 		r.customer_id,
-- 		@customer_rank:=CASE
-- 			WHEN @current_customer IS NULL THEN 1
-- 			WHEN @current_customer = r.customer_id THEN @customer_rank
-- 			ELSE @customer_rank + 1
-- 		END customer_rank,
-- 		@current_customer:=r.customer_id
-- 	FROM
-- 		sakila.rental r
-- 	WHERE
-- 		r.rental_date BETWEEN '2005-05-28 00:00:00' AND '2005-06-03 00:00:00'
-- 	ORDER BY r.customer_id , r.rental_date ASC
-- ) ranked
-- WHERE customer_rank <= 5

-- set @current_customer = null;
-- set @customer_rank = null;

-- クエリ3 MySQL8のみ動作 ウィンドウ関数の利用
SELECT rental_id, rental_date, customer_id
FROM (
	SELECT 
		r.rental_id,
		r.rental_date,
		r.customer_id,
		DENSE_RANK() over(order by r.customer_id) as customer_rank 
	FROM
		sakila.rental r
	WHERE
		r.rental_date BETWEEN '2005-05-28 00:00:00' AND '2005-06-03 00:00:00'
	ORDER BY r.customer_id , r.rental_date ASC
) ranked
WHERE customer_rank <= 5