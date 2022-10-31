# Ref

https://zudoh.com/mysql/research-next-key-lock-and-insert-intention-gap-lock

https://kenken0807.hatenablog.com/entry/2016/11/29/150613

# operation

```
Trx1: begin;
Trx2: begin;
Trx1: DELETE FROM test WHERE secondaryId = 80;
Trx2: DELETE FROM test WHERE secondaryId = 90;
Trx1: INSERT INTO test VALUES (80, 80); // ここでTrx1がロックが取得できずに待ち状態になります
Trx2: INSERT INTO test VALUES (90, 90); // ここでTrx2もロックを取得できずに待ち状態となり、Trx1とのデッドロック状態となります
```

# Result

```
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
```


```
mysql> SHOW ENGINE INNODB STATUS\G
```

```
------------------------
LATEST DETECTED DEADLOCK
------------------------
2022-10-31 07:12:18 0x7f4ce02ae700
*** (1) TRANSACTION:
TRANSACTION 1809, ACTIVE 44 sec inserting
mysql tables in use 1, locked 1
LOCK WAIT 3 lock struct(s), heap size 1136, 2 row lock(s), undo log entries 1
MySQL thread id 11, OS thread handle 139968155420416, query id 303 172.22.0.1 root update
insert into test values (80, 80)
*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 23 page no 4 n bits 72 index idxSecondaryId of table `sample`.`test` trx id 1809 lock_mode X insert intention waiting
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** (2) TRANSACTION:
TRANSACTION 1810, ACTIVE 29 sec inserting
mysql tables in use 1, locked 1
3 lock struct(s), heap size 1136, 2 row lock(s), undo log entries 1
MySQL thread id 12, OS thread handle 139968155150080, query id 304 172.22.0.1 root update
insert into test values (90, 90)
*** (2) HOLDS THE LOCK(S):
RECORD LOCKS space id 23 page no 4 n bits 72 index idxSecondaryId of table `sample`.`test` trx id 1810 lock_mode X
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 23 page no 4 n bits 72 index idxSecondaryId of table `sample`.`test` trx id 1810 lock_mode X insert intention waiting
Record lock, heap no 1 PHYSICAL RECORD: n_fields 1; compact format; info bits 0
 0: len 8; hex 73757072656d756d; asc supremum;;

*** WE ROLL BACK TRANSACTION (2)
------------
TRANSACTIONS
------------
Trx id counter 1827
Purge done for trx's n:o < 1827 undo n:o < 0 state: running but idle
History list length 0
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 421443604006336, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421443604003576, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 421443604002656, not started
0 lock struct(s), heap size 1136, 0 row lock(s)
---TRANSACTION 1822, ACTIVE 468 sec
3 lock struct(s), heap size 1136, 3 row lock(s), undo log entries 2
MySQL thread id 13, OS thread handle 139968155420416, query id 322 172.22.0.1 root
---TRANSACTION 1819, ACTIVE 501 sec
4 lock struct(s), heap size 1136, 3 row lock(s)
MySQL thread id 12, OS thread handle 139968155150080, query id 323 172.22.0.1 root
```
