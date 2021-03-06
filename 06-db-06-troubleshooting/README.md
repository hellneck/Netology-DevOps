# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
нужно прервать. 

Вы как инженер поддержки решили произвести данную операцию:
- напишите список операций, которые вы будете производить для остановки запроса пользователя
  * 1. Получить ID текущей операции через db.currentOp()
    1. Убить opp через db.killOp()
- предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB  

    *  Чтобы избужать долгих запросов, необходимо постороить/перестроить соответствующий индекс


## Задача 2

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса. 

При масштабировании сервиса до N реплик вы увидели, что:
- сначала рост отношения записанных значений к истекшим
- Redis блокирует операции записи

Как вы думаете, в чем может быть проблема?  
  
  * В Redis есть два способа очистить просроченные записи: "ленивый" и "активный". В случае с ленивым - просроченные записи запрашиваются командой, активный способ - повторяется каждые 100 миллисекунд и проводит записи в состояние устаревшие, затем данные записи исключаются. ACTIVE_EXPIRE_CYCLE_LOOKUPS_PER_LOOP по умолчанию имеет значение 20, таким образом за раз можно пометить и очистить около 200 устаревших записей. Процесс проверки зациклится и мы ощутим задержки, а потом и вовсе не будут приниматься данные на запись, если появятся истекшие записи более 25% по отношению ко всем. В данном случае как раз так и получается. Такой подход необходим, чтобы не использовать слишком много памяти для ключей, срок действия которых уже истек.
 
## Задача 3

Перед выполнением задания познакомьтесь с документацией по [Common Mysql errors](https://dev.mysql.com/doc/refman/8.0/en/common-errors.html).

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:
```python
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

Как вы думаете, почему это начало происходить и как локализовать проблему?

Какие пути решения данной проблемы вы можете предложить?

  * Предполагаю что ошибки начали возникать из-за роста нагрузки.  
В качестве решения можно предложить:
     1. Увеличить значение параметров : connect_timeout, interactive_timeout, wait_timeout
     2. Добавить ресурсов на машине
     3. Создать индексы для оптимизации  и ускорения запросов (определить по плану запросов)

      Так же могут быть сбои на сетевой инфраструктуре, в таком случае необходимо увеличивать net_read_timeout.
Как дополнительный вариант можно расширить максимальное число соединений :  max_connections.

## Задача 4

Перед выполнением задания ознакомтесь со статьей [Common PostgreSQL errors](https://www.percona.com/blog/2020/06/05/10-common-postgresql-errors/) из блога Percona.

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с 
большим объемом данных лучше, чем MySQL.

После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит?  

Как бы вы решили данную проблему?

 * Когда памяти не хватает, вызывается oom-killer и уничтожается процесс PostgreSQL. Необходимо проверить настройки сервиса в части памяти, внести корректировки.
---
