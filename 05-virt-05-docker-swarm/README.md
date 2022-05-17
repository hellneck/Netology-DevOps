# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm"

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
  * В режиме `global` сервис будет запущен в одном экземпляре на всех возможных нодах.  
    В режиме `replication` n-ое кол-во контейнеров для данного сервиса будет запущено на всех доступных нодах.
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
  * Алгоритм поддержания распределенного консенсуса — `Raft`
- Что такое Overlay Network?
  * Overlay-сеть создает подсеть, которую могут использовать контейнеры в разных хостах swarm-кластера. Контейнеры на разных физических хостах могут обмениваться данными по overlay-сети (если все они прикреплены к одной сети).

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```
```bash
[root@node01 ~]# docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
lobv6rxze39a3is878cdpgdyx *   node01.netology.yc   Ready     Active         Leader           20.10.16
720n6hnw2w9z9k21znfdyvp46     node02.netology.yc   Ready     Active         Reachable        20.10.16
m39yzvqb3dut5inaz3yy3bueu     node03.netology.yc   Ready     Active         Reachable        20.10.16
vg7skfi2p0snjijlotz746ets     node04.netology.yc   Ready     Active                          20.10.16
zqwve8t9k9dgucevnyti5ld2g     node05.netology.yc   Ready     Active                          20.10.16
ixx02u2kabkkezry1m5rhbx1l     node06.netology.yc   Ready     Active                          20.10.16
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```
```bash
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ihqufibxsdfq   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
x3tehan0qcv7   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
mdbh8xbkdbds   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
hj45kyfh3i1g   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
q3ezd2pbe2pc   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
sgwrv5dg2gud   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
27h76puowoco   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
lbiru5jbhcgs   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
```
## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```
```bash
[root@node01 ~]# docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-aZCQzxRWt12wgCjfFHd6w2MrfMkeq/Do1CdPGZN7aQ0

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.

[root@node01 ~]# systemctl restart docker
[root@node01 ~]# docker service ls
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.

[root@node01 ~]# docker swarm unlock
Please enter unlock key: 
[root@node01 ~]# docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
ihqufibxsdfq   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0    
x3tehan0qcv7   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
mdbh8xbkdbds   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest                         
hj45kyfh3i1g   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest                      
q3ezd2pbe2pc   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4           
sgwrv5dg2gud   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0   
27h76puowoco   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0       
lbiru5jbhcgs   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0 
```

- `docker swarm update --autolock=true` включет автоблокировку swarm на уже запущенном swarm. При рестарте docker нужно будет ввести ранее сгенерированный ключ, чтобы разблокировать swarm. Используется для защиты ключа шифрования TLS и ключа шифрования журнала Raft.