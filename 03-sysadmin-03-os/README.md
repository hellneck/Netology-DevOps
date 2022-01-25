# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

   * `chdir("/tmp")`


2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

    * `openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3`


3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

    * ```bash
      vagrant@ubuntu-impish:~$ ping 192.168.33.1 >> log.txt &
      [1] 7154
      vagrant@ubuntu-impish:~$ sudo lsof -p 7154
      COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF  NODE NAME
      ping    7154 vagrant    1w   REG    8,1     3270    20 /home/vagrant/log.txt
      vagrant@ubuntu-impish:~$ rm log.txt
      vagrant@ubuntu-impish:~$ sudo lsof -p 7154
      ping    7154 vagrant    1w   REG    8,1     9271    20 /home/vagrant/log.txt (deleted)
      vagrant@ubuntu-impish:~$ sudo ls -la -L /proc/7154/fd/1
      -rw-rw-r-- 0 vagrant vagrant 63073 Jan 25 14:17 /proc/7154/fd/1
      vagrant@ubuntu-impish:~$ sudo -i
      root@ubuntu-impish:~# cat /dev/null > /proc/7154/fd/1
      root@ubuntu-impish:~# ls -la -L /proc/7154/fd/1
      -rw-rw-r-- 0 vagrant vagrant 0 Jan 25 14:29 /proc/7154/fd/1
       ```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

   * Процесс при завершении (как нормальном, так и в результате не обрабатываемого сигнала) освобождает все свои ресурсы и становится «зомби» — пустой записью в таблице процессов, хранящей статус завершения, предназначенный для чтения родительским процессом. Зомби-процесс существует до тех пор, пока родительский процесс не прочитает его статус с помощью системного вызова wait(), в результате чего запись в таблице процессов будет освобождена.


5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).

    * `vagrant@ubuntu-impish:~$ sudo opensnoop-bpfcc`  
      PID    COMM               FD ERR PATH  
481    multipathd         11   0 /sys/devices/pci0000:00/0000:00:14.0/host2/target2:0:0/2:0:0:0/state  
481    multipathd         11   0 /sys/devices/pci0000:00/0000:00:14.0/host2/target2:0:0/2:0:0:0/block/sda/size  
481    multipathd         11   0 /sys/devices/pci0000:00/0000:00:14.0/host2/target2:0:0/2:0:0:0/state  
481    multipathd         -1   2 /sys/devices/pci0000:00/0000:00:14.0/host2/target2:0:0/2:0:0:0/vpd_pg80  
481    multipathd         11   0 /sys/devices/pci0000:00/0000:00:14.0/host2/target2:0:0/2:0:0:0/vpd_pg83  
351    systemd-journal    30   0 /proc/481/status  
351    systemd-journal    30   0 /proc/481/status  
351    systemd-journal    30   0 /proc/481/comm  
351    systemd-journal    30   0 /proc/481/cmdline  
351    systemd-journal    30   0 /proc/481/status  
351    systemd-journal    30   0 /proc/481/attr/current  
351    systemd-journal    30   0 /proc/481/sessionid  
351    systemd-journal    30   0 /proc/481/loginuid  
351    systemd-journal    30   0 /proc/481/cgroup  
351    systemd-journal    -1   2 /run/systemd/units/log-extra-fields:multipathd.service  
351    systemd-journal    -1   2 /run/log/journal/22ce5f8a06664fb78ccb7abf9acd5770/system.journal  
    


6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

    * Вызов `uname()`
    * `Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease,  ver‐
       sion, domainname}.`


7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?

   * Оператор AND (`&&`) будет выполнять вторую команду только в том случае, если при выполнении первой команды SUCCEEDS, т.е. состояние выхода первой команды равно «0» — программа выполнена успешно.  
   * Оператор (`;`) позволяет запускать несколько команд за один раз, и выполнение команды происходит последовательно.  
   * `root@netology1:~# test -d /tmp/some_dir && echo Hi` - в этом случае `echo Hi` выполнится только при успешном завершении команды `test`.  
   * `set -e` - прерывает работу сценария при появлении первой же ошибки (когда команда возвращает ненулевой код завершения). 



8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

   * `- e` - Прерывает работу сценария при появлении первой же ошибки (когда команда возвращает ненулевой код завершения)  
   * `- u` - При попытке обращения к неопределенным переменным, выдает сообщение об ошибке и прерывает работу сценария  
   * `- x` - Режим отладки. Перед выполнением команды печатает её со всеми уже развернутыми подстановками и вычислениями  
   * `- o` - Устаналивает или снимает опцию по её длинному имени. Например set -o noglob. Если никакой опции не задано, то выводится список всех опций и их статус  
   * Использование в сценариях должно повышать детализацию вывода ошибок, и завершать сценарий при наличии ошибок, на любом этапе выполнения сценария


9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

   * ```bash
     vagrant@ubuntu-impish:~$ ps -o stat
     STAT
     Ss
     R+
     ```
   * `S` - Процессы ожидающие завершения (спящие с прерыванием "сна")
   * `R` - Процесс выполняется в данный момент
   
