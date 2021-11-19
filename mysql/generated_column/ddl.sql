-- Step1: STORED (物理) でGeneratedカラムを追加する
ALTER TABLE rental ADD test varchar(255) AS (CONCAT(`return_date`, '-', `last_update`)) STORED;
-- Query OK, 16044 rows affected (0.44 sec)
-- Records: 16044  Duplicates: 0  Warnings: 0

-- [確認] 追加した時点でカラムの値が追加される
select * from rental limit 3;
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- | rental_id | rental_date         | inventory_id | customer_id | return_date         | staff_id | last_update         | test                                    |
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- |         1 | 2005-05-24 22:53:30 |          367 |         130 | 2005-05-26 22:04:30 |        1 | 2006-02-15 21:30:53 | 2005-05-26 22:04:30-2006-02-15 21:30:53 |
-- |         2 | 2005-05-24 22:54:33 |         1525 |         459 | 2005-05-28 19:40:33 |        1 | 2006-02-15 21:30:53 | 2005-05-28 19:40:33-2006-02-15 21:30:53 |
-- |         3 | 2005-05-24 23:03:39 |         1711 |         408 | 2005-06-01 22:12:39 |        1 | 2006-02-15 21:30:53 | 2005-06-01 22:12:39-2006-02-15 21:30:53 |
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- 3 rows in set (0.00 sec)

-- Step2: Generatedカラムを普通のカラムに変更する
ALTER TABLE rental MODIFY test varchar(255);
-- Query OK, 16044 rows affected (0.39 sec)
-- Records: 16044  Duplicates: 0  Warnings: 0

-- [確認] 問題なく変更された
select * from rental limit 3;
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- | rental_id | rental_date         | inventory_id | customer_id | return_date         | staff_id | last_update         | test                                    |
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- |         1 | 2005-05-24 22:53:30 |          367 |         130 | 2005-05-26 22:04:30 |        1 | 2006-02-15 21:30:53 | 2005-05-26 22:04:30-2006-02-15 21:30:53 |
-- |         2 | 2005-05-24 22:54:33 |         1525 |         459 | 2005-05-28 19:40:33 |        1 | 2006-02-15 21:30:53 | 2005-05-28 19:40:33-2006-02-15 21:30:53 |
-- |         3 | 2005-05-24 23:03:39 |         1711 |         408 | 2005-06-01 22:12:39 |        1 | 2006-02-15 21:30:53 | 2005-06-01 22:12:39-2006-02-15 21:30:53 |
-- +-----------+---------------------+--------------+-------------+---------------------+----------+---------------------+-----------------------------------------+
-- 3 rows in set (0.01 sec)

-- [確認] 問題なく変更された
show create table rental\G
-- *************************** 1. row ***************************
--        Table: rental
-- Create Table: CREATE TABLE `rental` (
--   `rental_id` int(11) NOT NULL AUTO_INCREMENT,
--   `rental_date` datetime NOT NULL,
--   `inventory_id` mediumint(8) unsigned NOT NULL,
--   `customer_id` smallint(5) unsigned NOT NULL,
--   `return_date` datetime DEFAULT NULL,
--   `staff_id` tinyint(3) unsigned NOT NULL,
--   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   `test` varchar(255) DEFAULT NULL,
--   PRIMARY KEY (`rental_id`),
--   UNIQUE KEY `rental_date` (`rental_date`,`inventory_id`,`customer_id`),
--   KEY `idx_fk_inventory_id` (`inventory_id`),
--   KEY `idx_fk_customer_id` (`customer_id`),
--   KEY `idx_fk_staff_id` (`staff_id`),
--   CONSTRAINT `fk_rental_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON UPDATE CASCADE,
--   CONSTRAINT `fk_rental_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`inventory_id`) ON UPDATE CASCADE,
--   CONSTRAINT `fk_rental_staff` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`staff_id`) ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4
-- 1 row in set (0.01 sec)
