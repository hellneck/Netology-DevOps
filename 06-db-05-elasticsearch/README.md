# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

```dockerfile
FROM centos:7

ENV PATH=/usr/lib:/usr/lib/jvm/jre-11/bin:$PATH

RUN yum install java-11-openjdk, perl-Digest-SHA -y &&  yum clean all && \
    rm -rf /var/cache/yum

COPY elasticsearch-8.2.2-linux-x86_64.tar.gz /

RUN tar -xzf elasticsearch-8.2.2-linux-x86_64.tar.gz && rm elasticsearch-8.2.2-linux-x86_64.tar.gz
    
ADD elasticsearch.yml /elasticsearch-8.2.2/config/

ENV ES_HOME=/elasticsearch-8.2.2
RUN groupadd elasticsearch \
    && useradd -g elasticsearch elasticsearch
    
RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data \
    && chown -R elasticsearch:elasticsearch /elasticsearch-8.2.2/
RUN mkdir /elasticsearch-8.2.2/snapshots &&\
    chown elasticsearch:elasticsearch /elasticsearch-8.2.2/snapshots
    
EXPOSE 9200/tcp

USER elasticsearch

CMD ["/elasticsearch-8.2.2/bin/elasticsearch"]
```

```yaml
cluster.name: netology
node.name: "netology_test"
discovery.type: single-node
path.data: /var/lib/data
path.logs: /var/lib/logs
path.repo: /elasticsearch-8.2.2/snapshots
network.host: 0.0.0.0
xpack.security.enabled: false
```
* [образ в репозитории dockerhub](https://hub.docker.com/repository/docker/hellneck/elasticsearch)

```json
→ curl -X GET 'http://localhost:9200'                 
{
  "name" : "netology_test",
  "cluster_name" : "netology",
  "cluster_uuid" : "s6wS7U4bRJaIyCAo3oYEcA",
  "version" : {
    "number" : "8.2.2",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "9876968ef3c745186b94fdabd4483e01499224ef",
    "build_date" : "2022-05-25T15:47:06.259735307Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```


## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

```bash
→ curl -X PUT localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
→ curl -X PUT localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
→ curl -X PUT localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```

```bash
→ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   ind-3 SUh6YvrLRyOCzd-xVU1QCg   4   2          0            0       900b           900b
yellow open   ind-2 5Ob5f5yCQL-oWSVVfQFeuA   2   1          0            0       450b           450b
green  open   ind-1 Ve_rESHNREmv1C1ivgGQuw   1   0          0            0       225b           225b

→ curl -X GET 'http://localhost:9200/_cluster/health/ind-1?pretty'
{
  "cluster_name" : "netology",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

→ curl -X GET 'http://localhost:9200/_cluster/health/ind-2?pretty'
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 2,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 2,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

→ curl -X GET 'http://localhost:9200/_cluster/health/ind-3?pretty'
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 4,
  "active_shards" : 4,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 8,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}

→ curl -X GET 'http://localhost:9200/_cluster/health/?pretty=true'
{
  "cluster_name" : "netology",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

* Часть индексов в статусе **yellow** потому, что у них указано число реплик больше чем число нод, соответственно некуда реплицировать.

```bash
→ curl -X DELETE 'http://localhost:9200/ind-1'
{"acknowledged":true}                                                                                     
→ curl -X DELETE 'http://localhost:9200/ind-2'
{"acknowledged":true}                                                                                               
→ curl -X DELETE 'http://localhost:9200/ind-3'
{"acknowledged":true}            
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`


```bash
→ curl -X PUT "http://localhost:9200/_snapshot/netology_backup" -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/elasticsearch-8.2.2/snapshots" }}'    
{"acknowledged":true}

→ curl -X GET 'http://localhost:9200/_snapshot/netology_backup?pretty'                                                                                                               
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/elasticsearch-8.2.2/snapshots"
    }
  }
}

→ curl -X PUT localhost:9200/test -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test"}

→ curl -X GET 'http://localhost:9200/test?pretty'                                                                                           
{
  "test" : {
    "aliases" : { },
    "mappings" : { },
    "settings" : {
      "index" : {
        "routing" : {
          "allocation" : {
            "include" : {
              "_tier_preference" : "data_content"
            }
          }
        },
        "number_of_shards" : "1",
        "provided_name" : "test",
        "creation_date" : "1654607428015",
        "number_of_replicas" : "0",
        "uuid" : "Z_r2tUwCRMunAjs1-q9Hdw",
        "version" : {
          "created" : "8020299"
        }
      }
    }
  }
}

→ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  Z_r2tUwCRMunAjs1-q9Hdw   1   0          0            0       225b           225b

→ curl -X PUT 'localhost:9200/_snapshot/netology_backup/elasticsearch?wait_for_completion=true'

{"snapshot":{"snapshot":"elasticsearch","uuid":"_FcMl480QciOvGme0I9PhQ","repository":"netology_backup","version_id":8020299,"version":"8.2.2","indices":["test",".geoip_databases"],"data_streams":[],"include_global_state":true,"state":"SUCCESS","start_time":"2022-06-07T13:15:19.806Z","start_time_in_millis":1654607719806,"end_time":"2022-06-07T13:15:20.811Z","end_time_in_millis":1654607720811,"duration_in_millis":1005,"failures":[],"shards":{"total":2,"failed":0,"successful":2},"feature_states":[{"feature_name":"geoip","indices":[".geoip_databases"]}]}}

→ docker exec -i 58bd8c907f60 ls -la /elasticsearch-8.2.2/snapshots
total 48
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Jun  7 13:15 .
drwxr-xr-x 1 elasticsearch elasticsearch  4096 Jun  7 09:15 ..
-rw-r--r-- 1 elasticsearch elasticsearch   846 Jun  7 13:15 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Jun  7 13:15 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Jun  7 13:15 indices
-rw-r--r-- 1 elasticsearch elasticsearch 18309 Jun  7 13:15 meta-_FcMl480QciOvGme0I9PhQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch   354 Jun  7 13:15 snap-_FcMl480QciOvGme0I9PhQ.dat

→ curl -X DELETE 'http://localhost:9200/test' 
{"acknowledged":true}

→ curl -X PUT localhost:9200/test-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
{"acknowledged":true,"shards_acknowledged":true,"index":"test-2"}

→ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 Jc8g5uZ3StWvH3M3bPh3OA   1   0          0            0       225b           225b

→ curl -X POST http://localhost:9200/_snapshot/netology_backup/elasticsearch/_restore -H 'Content-Type: application/json' -d'{"include_global_state":true}' 
{"accepted":true}

→ curl -X GET 'http://localhost:9200/_cat/indices?v'                                                                                                            
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 Jc8g5uZ3StWvH3M3bPh3OA   1   0          0            0       225b           225b
green  open   test   O-gvDuehRn2gL-bFv03iuw   1   0          0            0       225b           225b
```

---
