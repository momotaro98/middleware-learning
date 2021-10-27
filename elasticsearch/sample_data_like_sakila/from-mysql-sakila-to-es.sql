select concat('{ "index" : { "_index" : "rental", "_id" : "', rental.rental_id, '" } }
{ "rental_id" : "', rental.rental_id
,'" , "rental_date" : "', DATE_FORMAT(rental.rental_date, '%Y-%m-%dT%H:%i:%sZ')
,'" , "customer_id" : "', customer.customer_id
,'" , "customer_name" : "', customer.first_name,'" }')
from sakila.rental rental
join sakila.customer customer on rental.customer_id = customer.customer_id
where rental.rental_date between '2005-05-28 00:00:00' and '2005-06-03 00:00:00'