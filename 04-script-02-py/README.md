# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  |   File "<stdin>", line 1, in <module> TypeError: unsupported operand type(s) for +: 'int' and 'str'  |
| Как получить для переменной `c` значение 12?  | c=str(a)+b  |
| Как получить для переменной `c` значение 3?  | c=a+int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
# is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.abspath('sysadm-homeworks') + '/' + prepare_result)
        # break
```

### Вывод скрипта при запуске при тестировании:
```bash
cudo@VivoBook:~$ ./dz2.py 
/home/cudo/sysadm-homeworks/02-git-02-base/README.md
/home/cudo/sysadm-homeworks/03-sysadmin-04-os/README.md
/home/cudo/sysadm-homeworks/README.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

arg = sys.argv[1]
bash_command = ["cd "+ arg, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
# is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(arg + prepare_result)
        # break
```

### Вывод скрипта при запуске при тестировании:
```bash
cudo@VivoBook:~$ ./dz3.py /home/cudo/streisand/
/home/cudo/streisand/CONTRIBUTING.md
/home/cudo/streisand/Vagrantfile
/home/cudo/streisand/deploy/streisand-local.sh
/home/cudo/streisand/library/digital_ocean_droplet.py
/home/cudo/streisand/playbooks/azure.yml
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json

with open('conf.json') as json_file:
    conf = json.load(json_file)

for host, ip in conf.items():
    new_ip=socket.gethostbyname(host)
    
    if ip != new_ip:
        print ('[ERROR] {} IP mismatch: {} {}'.format(host,ip,new_ip))
        conf[host]=new_ip

for host, ip in conf.items():
    print('{} - {}'.format(host,ip))
    
with open('conf.json', "w") as json_file:
    json.dump(conf, json_file, indent=3)
```

### Вывод скрипта при запуске при тестировании:
```bash
cudo@VivoBook:~$ ./dz4.py 
[ERROR] drive.google.com IP mismatch: 64.233.165.194 64.233.164.194
[ERROR] mail.google.com IP mismatch: 64.233.163.19 209.85.233.19
[ERROR] google.com IP mismatch: 173.194.73.101 173.194.222.101
drive.google.com - 64.233.164.194
mail.google.com - 209.85.233.19
google.com - 173.194.222.101
```
