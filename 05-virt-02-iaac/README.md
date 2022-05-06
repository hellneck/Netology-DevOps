# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
  * Благодаря IaaC можно добиться скорости и уменьшения затрат на развертывание инфраструктуры, стабильности и безопасности ведь за провизионирование всех вычислительных, сетевых и служб хранения отвечает код, они каждый раз будут развертываться одинаково. Это означает, что стандарты безопасности можно легко и последовательно применять в разных компаниях. Восстановление в аварийных ситуациях — очень эффективный способ отслеживания инфраструктуры и повторного развертывания последнего работоспособного состояния после сбоя или катастрофы любого рода.
- Какой из принципов IaaC является основополагающим?
  * Основополагающим принципом IaaC я считаю  идемпотентность — исполнение одного и того же кода формирует одну и ту же исполняемую среду. Благодаря такому подходу достигается единообразие элементов инфраструктуры и их ожидаемое поведение, а также идемпотентность, как свойство системы принимать одно и то же состояние при одинаковых условиях вызова.


## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
  * Ansible использует существующую SSH инфраструктуру, тогда как другим системам требуется специальное PKI окружение. 
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?
  * На мой взгляд метод `Pull` более надежен за счет потребления меньших ресурсов при работе с большим кол-вом серверов. 


## Задача 3

Установить на личный компьютер:

- VirtualBox
```bash
andrey@vivobook:~$ virtualbox --help
Oracle VM VirtualBox VM Selector v6.1.32_Ubuntu
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```
- Vagrant
```bash
andrey@vivobook:~$ vagrant -v
Vagrant 2.2.19
```
- Ansible
```bash
 andrey@vivobook:~$ ansible --version
ansible 2.10.8
  config file = None
  configured module search path = ['/home/andrey/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.10.4 (main, Apr  2 2022, 09:04:19) [GCC 11.2.0]
```
*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
```bash
andrey@vivobook:~/VagrantTest$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
==> server1.netology: Clearing any previously set forwarded ports...
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/andrey/VagrantTest
==> server1.netology: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> server1.netology: flag to force provisioning. Provisioners marked to run always will still run.
andrey@vivobook:~/VagrantTest$ vagrant ssh
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri 06 May 2022 07:25:47 PM UTC

  System load:  0.8                Users logged in:          0
  Usage of /:   13.6% of 30.88GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 23%                IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1:    192.168.56.11
  Processes:    117


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Fri May  6 19:19:18 2022 from 10.0.2.2
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
