CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `encoded_id` char(50) NOT NULL,
  `start_at` DATETIME NOT NULL,
  `end_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_encoded_it` (`encoded_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
