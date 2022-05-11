
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.
   * [https://hub.docker.com/r/hellneck/nginx/tags](https://hub.docker.com/r/hellneck/nginx/tags)

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
```bash
andrey@vivobook:~$ docker run -d --name centos -v /home/andrey/data/:/data centos ping 8.8.8.8
9a72ff4169e5b33f911cd794ef0758cb2b8c7eff6c01d3bde2dc1c6c04321079
andrey@vivobook:~$ docker ps
CONTAINER ID   IMAGE     COMMAND          CREATED         STATUS         PORTS     NAMES
9a72ff4169e5   centos    "ping 8.8.8.8"   4 seconds ago   Up 3 seconds             centos
andrey@vivobook:~$ ll data/
итого 8
drwxrwxr-x  2 andrey andrey 4096 мая 11 21:23 ./
drwxr-x--- 26 andrey andrey 4096 мая 11 21:23 ../
```
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
```bash
andrey@vivobook:~$ docker run -d --name debian -v /home/andrey/data/:/data debian sleep 9999
d819266e4c39677bfb205e256fd50e2f0181d83fb9ad22f8aceec6c41071c6b5
andrey@vivobook:~$ docker ps
CONTAINER ID   IMAGE     COMMAND          CREATED          STATUS          PORTS     NAMES
d819266e4c39   debian    "sleep 9999"     28 seconds ago   Up 27 seconds             debian
9a72ff4169e5   centos    "ping 8.8.8.8"   8 minutes ago    Up 8 minutes              centos
```
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
```bash
andrey@vivobook:~$ docker exec -it centos /bin/sh -c "touch /data/1.txt"
andrey@vivobook:~$ ll data/
итого 8
drwxrwxr-x  2 andrey andrey 4096 мая 11 21:44 ./
drwxr-x--- 26 andrey andrey 4096 мая 11 21:23 ../
-rw-r--r--  1 root   root      0 мая 11 21:44 1.txt
```
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
```bash
andrey@vivobook:~$ touch data/2.txt
andrey@vivobook:~$ ll data/
итого 8
drwxrwxr-x  2 andrey andrey 4096 мая 11 21:46 ./
drwxr-x--- 26 andrey andrey 4096 мая 11 21:23 ../
-rw-r--r--  1 root   root      0 мая 11 21:44 1.txt
-rw-rw-r--  1 andrey andrey    0 мая 11 21:46 2.txt
```
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.
```bash
andrey@vivobook:~$ docker exec -it debian /bin/sh -c "ls -la /data"
total 8
drwxrwxr-x 2 1000 1000 4096 May 11 18:46 .
drwxr-xr-x 1 root root 4096 May 11 18:39 ..
-rw-r--r-- 1 root root    0 May 11 18:44 1.txt
-rw-rw-r-- 1 1000 1000    0 May 11 18:46 2.txt
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

   * [https://hub.docker.com/r/hellneck/ansible/tags](https://hub.docker.com/r/hellneck/ansible/tags)