CREATE TEMPORARY TABLE tmp_big_tb(
    SELECT
        d1.num + d2.num*10 + d3.num*100 + d4.num*1000 + d5.num*10000 + d6.num*100000 as num
    FROM
        digit d1, digit d2, digit d3, digit d4, digit d5, digit d6
);

-- Remove index keys temporarily

DROP INDEX idx_encoded_id ON events;

DROP INDEX start_at_index ON events;

-- Bulk insert

START TRANSACTION;
INSERT INTO events(encoded_id, start_at, end_at)
    select 
        CONCAT("2021-07-12_1655_", @num:=@num+1),
        '2021-08-01 00:00:00' + interval @num * 2 minute,
        '2021-08-01 00:00:00' + interval (@num *2) + 1 minute
    from 
        tmp_big_tb,    
        (select @num:=-1) num
    limit 
        10
;
COMMIT;

-- Restore index keys

ALTER TABLE events ADD CONSTRAINT idx_encoded_id UNIQUE (encoded_id);

create index start_at_index on events(start_at);