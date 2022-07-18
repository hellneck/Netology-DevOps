# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
   ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master
    → ansible-playbook site.yml -i inventory/test.yml 

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [localhost]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": 12
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
   ```
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
   ```
   some_fact: all default fact
   ```
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
   ```bash
     in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-playbook site.yml -i inventory/prod.yml

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el"
    }
    ok: [ubuntu] => {
        "msg": "deb"
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
   ```
     in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → cat group_vars/deb/examp.yml       
    ---
      some_fact: "deb default fact"                                                                                                                                                                        

      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → cat group_vars/el/examp.yml 
    ---
    some_fact: "el default fact" 
   ```
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
   ```bash
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-playbook site.yml -i inventory/prod.yml

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [ubuntu]
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
   ```
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
   ```bash
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-vault encrypt group_vars/deb/examp.yml      
    New Vault password: 
    Confirm New Vault password: 
    Encryption successful

      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-vault encrypt group_vars/el/examp.yml  
    New Vault password: 
    Confirm New Vault password: 
    Encryption successful
   ```
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
   ```bash
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass 
    Vault password: 

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [centos7]
    ok: [ubuntu]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
   ```
9.  Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
    ```bash
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-doc -t connection -l

    ...

    local                          execute on controller
    ```
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
    ```
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
      → cat inventory/prod.yml     
      ---
        el:
          hosts:
            centos7:
              ansible_connection: docker
        deb:
          hosts:
            ubuntu:
              ansible_connection: docker
        local:
          hosts:
            localhost:
              ansible_connection: local
    ```
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
    ```bash
     in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
    Vault password: 

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [ubuntu]
    ok: [localhost]
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "Ubuntu"
    }
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "all default fact"
    }
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
    ```
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
   ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-vault decrypt group_vars/deb/examp.yml                  
    Vault password: 
    Decryption successful

      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-vault decrypt group_vars/el/examp.yml 
    Vault password: 
    Decryption successful
   ```
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
   ```bash
     in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-vault encrypt_string                                    
    New Vault password: 
    Confirm New Vault password: 
    Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
    PaSSw0rd
    Encryption successful
    !vault |
              $ANSIBLE_VAULT;1.1;AES256
              35663037353562346166326663633765613538323235623931636164353035376530356363396436
              6663363666323331366238363839376238363136373363660a646565633438373465303836303761
              61396637306563636330653434366339356266393361353231353666643338356531343430646237
              6438353339643631310a343663616236653733663930353635643735326564623431316436613236
              6264                                                                               
    
      in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → cat group_vars/all/examp.yml 
    ---
    some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          35663037353562346166326663633765613538323235623931636164353035376530356363396436
          6663363666323331366238363839376238363136373363660a646565633438373465303836303761
          61396637306563636330653434366339356266393361353231353666643338356531343430646237
          6438353339643631310a343663616236653733663930353635643735326564623431316436613236
          6264
   ```
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
   ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!)
    → ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
    Vault password: 

    PLAY [Print os facts] **********************************************************************************************************************************************************************************

    TASK [Gathering Facts] *********************************************************************************************************************************************************************************
    ok: [ubuntu]
    ok: [localhost]
    ok: [centos7]

    TASK [Print OS] ****************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "Ubuntu"
    }
    ok: [centos7] => {
        "msg": "CentOS"
    }
    ok: [ubuntu] => {
        "msg": "Ubuntu"
    }

    TASK [Print fact] **************************************************************************************************************************************************************************************
    ok: [localhost] => {
        "msg": "PaSSw0rd"
    }
    ok: [centos7] => {
        "msg": "el default fact"
    }
    ok: [ubuntu] => {
        "msg": "deb default fact"
    }

    PLAY RECAP *********************************************************************************************************************************************************************************************
    centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
   ```
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
  ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!?)
  → cat inventory/prod.yml                       
  ---
    el:
      hosts:
        centos7:
          ansible_connection: docker
    deb:
      hosts:
        ubuntu:
          ansible_connection: docker
    local:
      hosts:
        localhost:
          ansible_connection: local
    fed:
      hosts:
        fedora:
          ansible_connection: docker
  ```
  ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!?)
  → cat group_vars/fed/examp.yml 
  some_fact: "fed default fact"
  ```
  ```bash
  → ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
  Vault password: 

  PLAY [Print os facts] **********************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [ubuntu]
  ok: [localhost]
  ok: [centos7]
  ok: [fedora]

  TASK [Print OS] ****************************************************************************************************************************************************************************************
  ok: [localhost] => {
      "msg": "Ubuntu"
  }
  ok: [centos7] => {
      "msg": "CentOS"
  }
  ok: [ubuntu] => {
      "msg": "Ubuntu"
  }
  ok: [fedora] => {
      "msg": "Fedora"
  }

  TASK [Print fact] **************************************************************************************************************************************************************************************
  ok: [localhost] => {
      "msg": "PaSSw0rd"
  }
  ok: [centos7] => {
      "msg": "el default fact"
  }
  ok: [ubuntu] => {
      "msg": "deb default fact"
  }
  ok: [fedora] => {
      "msg": "fed default fact"
  }

  PLAY RECAP *********************************************************************************************************************************************************************************************
  centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
  ```bash
  #!/bin/bash

  docker run -d --name=fedora --rm pycontribs/fedora:latest sleep 1000
  docker run -d --name=centos7 --rm pycontribs/centos:7 sleep 1000
  docker run -d --name=ubuntu --rm pycontribs/ubuntu:latest sleep 1000

  ansible-playbook site.yml -i inventory/prod.yml

  docker stop fedora centos7 ubuntu
  ```
  ```bash
    in ~/mnt-homeworks/08-ansible-01-base/playbook at master(!?)
  → ./ansible.sh   
  5ae5a2a860029888471e75ce75d1c22d3c4d66c6d3cd50fa1d5aed80cc4a2ede
  e7a67f3320bd6527ae6c46051f2deaa990cae599ea00efba6ce697adcb93f65b
  05a97fee739cea8dea08ca4af44c720e2b8e8b2b8bfbf71301f197f65a50ea27

  PLAY [Print os facts] **********************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [localhost]
  ok: [fedora]
  ok: [ubuntu]
  ok: [centos7]

  TASK [Print OS] ****************************************************************************************************************************************************************************************
  ok: [localhost] => {
      "msg": "Ubuntu"
  }
  ok: [centos7] => {
      "msg": "CentOS"
  }
  ok: [ubuntu] => {
      "msg": "Ubuntu"
  }
  ok: [fedora] => {
      "msg": "Fedora"
  }

  TASK [Print fact] **************************************************************************************************************************************************************************************
  ok: [localhost] => {
      "msg": "PaSSw0rd"
  }
  ok: [centos7] => {
      "msg": "el default fact"
  }
  ok: [ubuntu] => {
      "msg": "deb default fact"
  }
  ok: [fedora] => {
      "msg": "fed default fact"
  }

  PLAY RECAP *********************************************************************************************************************************************************************************************
  centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

  fedora
  centos7
  ubuntu
  ```
* Так же можно было применить docker-compose
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

---