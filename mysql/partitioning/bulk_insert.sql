-- Remove index keys temporarily

DROP INDEX idx_encoded_id ON events;

DROP INDEX start_at_index ON events;

-- create tmp table for bulk insert

CREATE TEMPORARY TABLE tmp_big_tb(
    SELECT
        -- d1.num + d2.num*10 + d3.num*100 + d4.num*1000 + d5.num*10000 + d6.num*100000 + d7.num*1000000 + d8.num*10000000 as num
        true
    FROM
        -- digit d1, digit d2, digit d3, digit d4, digit d5, digit d6, digit d7, digit d8
        digit d1, digit d2, digit d3, digit d4, digit d5, digit d6, digit d7
);

-- Bulk insert
-- Official doc ref https://dev.mysql.com/doc/refman/5.6/en/optimizing-innodb-bulk-data-loading.html

SET unique_checks=0;
SET foreign_key_checks=0;

SET autocommit=0;
INSERT INTO events(encoded_id, start_at, end_at)
    select 
        CONCAT("2021-07-12_1823_", @num:=@num+1),
        '2021-08-01 00:00:00' + interval @num * 2 minute,
        '2021-08-01 00:00:00' + interval (@num *2) + 1 minute
    from 
        tmp_big_tb,    
        (select @num:=-1) num
    limit 
        10000000
;
COMMIT;

SET unique_checks=1;
SET foreign_key_checks=1;

-- Restore index keys

ALTER TABLE events ADD CONSTRAINT idx_encoded_id UNIQUE (encoded_id);

create index start_at_index on events(start_at);