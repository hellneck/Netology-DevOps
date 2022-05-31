# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
  * `\l`
- подключения к БД
  * `\c DBNAME`
- вывода списка таблиц
  * `\dt`
- вывода описания содержимого таблиц
  * `\d Table_name`
- выхода из psql
  * `\q`

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```bash
test_database=# ANALYZE VERBOSE orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE

test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename='orders' AND avg_width=(SELECT MAX(avg_width) FROM pg_stats WHERE tablename='orders');
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```bash
test_database=# ALTER TABLE orders RENAME TO orders_old;
ALTER TABLE
test_database=# CREATE TABLE orders (id integer, title varchar(80), price integer) PARTITION BY RANGE (price);
CREATE TABLE
test_database=# CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (0) TO (500);
CREATE TABLE
test_database=# CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (500) TO (999999999);
CREATE TABLE
test_database=# INSERT INTO orders (id, title, price) SELECT * FROM orders_old;
INSERT 0 8

test_database=# select * from orders_2;
 id |        title         | price 
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# select * from orders_1;
 id |       title        | price 
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# \dt
                 List of relations
 Schema |    Name    |       Type        |  Owner   
--------+------------+-------------------+----------
 public | orders     | partitioned table | postgres
 public | orders_1   | table             | postgres
 public | orders_2   | table             | postgres
 public | orders_old | table             | postgres
(4 rows)

test_database=# EXPLAIN SELECT * FROM orders WHERE price =499;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on orders_2  (cost=0.00..14.75 rows=2 width=186)
   Filter: (price = 499)
(2 rows)

test_database=# EXPLAIN SELECT * FROM orders WHERE price = 500;
                        QUERY PLAN                         
-----------------------------------------------------------
 Seq Scan on orders_1  (cost=0.00..14.75 rows=2 width=186)
   Filter: (price = 500)
(2 rows)
```
* При изначальном проектировании таблицы orders нужно было сделать ее секционированной.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
root@390e29584959:/# pg_dump -U postgres test_database > /var/backup/postgresql/dump_test_database.sql

root@390e29584959:/# ls -la /var/backup/postgresql/
total 12
drwxr-xr-x 2 root root 4096 May 31 11:41 .
drwxr-xr-x 3 root root 4096 May 31 11:41 ..
-rw-r--r-- 1 root root 2951 May 31 11:41 dump_test_database.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

* В данном случае уникальность можно добавить с помощью `INDEX`. **PRIMARY KEY** и **UNIQUE** не подходят, т.к. уже есть партиционный столбец с ключем `price`.

```bash
test_database=# CREATE INDEX ON orders ((lower(title)));
CREATE INDEX

test_database=# \d orders
                Partitioned table "public.orders"
 Column |         Type          | Collation | Nullable | Default 
--------+-----------------------+-----------+----------+---------
 id     | integer               |           |          | 
 title  | character varying(80) |           |          | 
 price  | integer               |           |          | 
Partition key: RANGE (price)
Indexes:
    "orders_lower_idx" btree (lower(title::text))
Number of partitions: 1 (Use \d+ to list them.)
```
---