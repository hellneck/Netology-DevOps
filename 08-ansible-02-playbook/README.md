# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook. 
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.
   ```yaml
    ---
    elasticsearch:
    hosts:
        elastic:
        ansible_connection: docker
    kibana:
    hosts:
        kibana:
        ansible_connection: docker
   ```
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
   ```yaml
    - name: Install Kibana
      hosts: kibana
      tasks:
        - name: Upload tar.gz kibana from remote URL
        get_url:
            url: "https://mirrors.huaweicloud.com/kibana/{{kibana_version}}/kibana-{{kibana_version}}-linux-x86_64.tar.gz"
            dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
            mode: 0755
            timeout: 60
            force: true
            validate_certs: false
        register: get_kibana
        until: get_kibana is succeeded
        tags: kibana
        - name: Create directrory for kibana
        file:
            state: directory
            path: "{{ kibana_home }}"
        tags: kibana
        - name: Extract kibana in the installation directory
        become: true
        unarchive:
            copy: false
            src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
            dest: "{{ kibana_home }}"
            extra_opts: [--strip-components=1]
            creates: "{{ kibana_home }}/bin/kibana"
        tags:
            - kibana
        - name: Set environment kibana
        become: true
        template:
            src: templates/kib.sh.j2
            dest: /etc/profile.d/kib.sh
        tags: kibana
   ```
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
  ```
    in ~/mnt-homeworks/08-ansible-02-playbook/playbook at master(!?)
  → ansible-lint site.yml 
  WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
  ``` 
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
  ```
    in ~/mnt-homeworks/08-ansible-02-playbook/playbook at master(!?)
  → ansible-playbook site.yml -i inventory/prod.yml --check

  PLAY [Install Java] ************************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [kibana]
  ok: [elastic]

  TASK [Set facts for Java 11 vars] **********************************************************************************************************************************************************************
  ok: [elastic]
  ok: [kibana]

  TASK [Upload .tar.gz file containing binaries from local storage] **************************************************************************************************************************************
  changed: [elastic]
  changed: [kibana]

  TASK [Ensure installation dir exists] ******************************************************************************************************************************************************************
  changed: [kibana]
  changed: [elastic]

  TASK [Extract java in the installation directory] ******************************************************************************************************************************************************
  An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
  fatal: [kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/18.0.2' must be an existing dir"}
  An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
  fatal: [elastic]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/18.0.2' must be an existing dir"}

  PLAY RECAP *********************************************************************************************************************************************************************************************
  elastic                    : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
  kibana                     : ok=4    changed=2    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
  ```
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
  ```
    in ~/mnt-homeworks/08-ansible-02-playbook/playbook at master(!?)
  → ansible-playbook site.yml -i inventory/prod.yml --diff 

  PLAY [Install Java] ************************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [kibana]
  ok: [elastic]

  TASK [Set facts for Java 11 vars] **********************************************************************************************************************************************************************
  ok: [elastic]
  ok: [kibana]

  TASK [Upload .tar.gz file containing binaries from local storage] **************************************************************************************************************************************
  diff skipped: source file size is greater than 104448
  changed: [elastic]
  diff skipped: source file size is greater than 104448
  changed: [kibana]

  TASK [Ensure installation dir exists] ******************************************************************************************************************************************************************
  --- before
  +++ after
  @@ -1,4 +1,4 @@
  {
      "path": "/opt/jdk/18.0.2",
  -    "state": "absent"
  +    "state": "directory"
  }

  changed: [elastic]
  --- before
  +++ after
  @@ -1,4 +1,4 @@
  {
      "path": "/opt/jdk/18.0.2",
  -    "state": "absent"
  +    "state": "directory"
  }

  changed: [kibana]

  TASK [Extract java in the installation directory] ******************************************************************************************************************************************************
  changed: [kibana]
  changed: [elastic]

  TASK [Export environment variables] ********************************************************************************************************************************************************************
  --- before
  +++ after: /home/vagrant/.ansible/tmp/ansible-local-28148941v5jogf0/tmpj_yct_gi/jdk.sh.j2
  @@ -0,0 +1,5 @@
  +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
  +#!/usr/bin/env bash
  +
  +export JAVA_HOME=/opt/jdk/18.0.2
  +export PATH=$PATH:$JAVA_HOME/bin
  \ No newline at end of file

  changed: [elastic]
  --- before
  +++ after: /home/vagrant/.ansible/tmp/ansible-local-28148941v5jogf0/tmpykrobx4p/jdk.sh.j2
  @@ -0,0 +1,5 @@
  +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
  +#!/usr/bin/env bash
  +
  +export JAVA_HOME=/opt/jdk/18.0.2
  +export PATH=$PATH:$JAVA_HOME/bin
  \ No newline at end of file

  changed: [kibana]

  PLAY [Install Elasticsearch] ***************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [elastic]

  TASK [Upload tar.gz Elasticsearch from remote URL] *****************************************************************************************************************************************************
  changed: [elastic]

  TASK [Create directrory for Elasticsearch] *************************************************************************************************************************************************************
  --- before
  +++ after
  @@ -1,4 +1,4 @@
  {
      "path": "/opt/elastic/7.9.3",
  -    "state": "absent"
  +    "state": "directory"
  }

  changed: [elastic]

  TASK [Extract Elasticsearch in the installation directory] *********************************************************************************************************************************************
  changed: [elastic]

  TASK [Set environment Elastic] *************************************************************************************************************************************************************************
  --- before
  +++ after: /home/vagrant/.ansible/tmp/ansible-local-28148941v5jogf0/tmpz021ijfk/elk.sh.j2
  @@ -0,0 +1,5 @@
  +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
  +#!/usr/bin/env bash
  +
  +export ES_HOME=/opt/elastic/7.9.3
  +export PATH=$PATH:$ES_HOME/bin
  \ No newline at end of file

  changed: [elastic]

  PLAY [Install Kibana] **********************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [kibana]

  TASK [Upload tar.gz kibana from remote URL] ************************************************************************************************************************************************************
  changed: [kibana]

  TASK [Create directrory for kibana] ********************************************************************************************************************************************************************
  --- before
  +++ after
  @@ -1,4 +1,4 @@
  {
      "path": "/opt/kibana/7.9.2",
  -    "state": "absent"
  +    "state": "directory"
  }

  changed: [kibana]

  TASK [Extract kibana in the installation directory] ****************************************************************************************************************************************************
  changed: [kibana]

  TASK [Set environment kibana] **************************************************************************************************************************************************************************
  --- before
  +++ after: /home/vagrant/.ansible/tmp/ansible-local-28148941v5jogf0/tmp8h4eiq1z/kib.sh.j2
  @@ -0,0 +1,5 @@
  +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
  +#!/usr/bin/env bash
  +
  +export KIBANA_HOME=/opt/kibana/7.9.2
  +export PATH=$PATH:$KIBANA_HOME/bin
  \ No newline at end of file

  changed: [kibana]

  PLAY RECAP *********************************************************************************************************************************************************************************************
  elastic                    : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
  kibana                     : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
  ```
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
  ```
  → ansible-playbook site.yml -i inventory/prod.yml --diff

  PLAY [Install Java] ************************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [kibana]
  ok: [elastic]

  TASK [Set facts for Java 11 vars] **********************************************************************************************************************************************************************
  ok: [elastic]
  ok: [kibana]

  TASK [Upload .tar.gz file containing binaries from local storage] **************************************************************************************************************************************
  ok: [kibana]
  ok: [elastic]

  TASK [Ensure installation dir exists] ******************************************************************************************************************************************************************
  ok: [elastic]
  ok: [kibana]

  TASK [Extract java in the installation directory] ******************************************************************************************************************************************************
  skipping: [kibana]
  skipping: [elastic]

  TASK [Export environment variables] ********************************************************************************************************************************************************************
  ok: [kibana]
  ok: [elastic]

  PLAY [Install Elasticsearch] ***************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [elastic]

  TASK [Upload tar.gz Elasticsearch from remote URL] *****************************************************************************************************************************************************
  ok: [elastic]

  TASK [Create directrory for Elasticsearch] *************************************************************************************************************************************************************
  ok: [elastic]

  TASK [Extract Elasticsearch in the installation directory] *********************************************************************************************************************************************
  skipping: [elastic]

  TASK [Set environment Elastic] *************************************************************************************************************************************************************************
  ok: [elastic]

  PLAY [Install Kibana] **********************************************************************************************************************************************************************************

  TASK [Gathering Facts] *********************************************************************************************************************************************************************************
  ok: [kibana]

  TASK [Upload tar.gz kibana from remote URL] ************************************************************************************************************************************************************
  ok: [kibana]

  TASK [Create directrory for kibana] ********************************************************************************************************************************************************************
  ok: [kibana]

  TASK [Extract kibana in the installation directory] ****************************************************************************************************************************************************
  skipping: [kibana]

  TASK [Set environment kibana] **************************************************************************************************************************************************************************
  ok: [kibana]

  PLAY RECAP *********************************************************************************************************************************************************************************************
  elastic                    : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
  kibana                     : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0 
  ```
9.  Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

---
