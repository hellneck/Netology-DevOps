# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис
- строка 5 не правильно задан ip адрес
- стока 6 пропущена `,` после `}`
- строка 9 не хватает `"`
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : "7.1.7.5" 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json
import yaml

with open('default.json') as f:
    conf = json.load(f)

for host, ip in conf.items():
    new_ip=socket.gethostbyname(host)
    
    if ip != new_ip:
        print ('[ERROR] {} IP mismatch: {} {}'.format(host,ip,new_ip))
        conf[host]=new_ip

for host, ip in conf.items():
    print('{} - {}'.format(host,ip))
    
with open('default.json', "w") as f:
    json.dump(conf, f, indent=3)

srv = []    
for host, ip in conf.items():
    srv.append({host:ip})
    
with open('conf.json', "w") as json_file:
    json.dump(srv, json_file, indent=3)
    
with open('conf.yml', 'w') as yaml_file:
    yaml.dump(srv, yaml_file, explicit_start=True, explicit_end=True)
```

### Вывод скрипта при запуске при тестировании:
```bash
cudo@VivoBook:~$ ./script.py 
[ERROR] drive.google.com IP mismatch: 64.233.165.194 64.233.164.194
[ERROR] mail.google.com IP mismatch: 64.233.163.19 209.85.233.19
[ERROR] google.com IP mismatch: 173.194.73.101 173.194.222.138
drive.google.com - 64.233.164.194
mail.google.com - 209.85.233.19
google.com - 173.194.222.138
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
[
   {
      "drive.google.com": "64.233.164.194"
   },
   {
      "mail.google.com": "209.85.233.19"
   },
   {
      "google.com": "173.194.222.138"
   }
]
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
---
- drive.google.com: 64.233.164.194
- mail.google.com: 209.85.233.19
- google.com: 173.194.222.138
...
```
