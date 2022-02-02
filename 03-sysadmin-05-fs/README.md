# Домашнее задание к занятию "3.5. Файловые системы"

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

   * Нет не могут. Потому что, они ссылаюся на один и тот же объект, имеют такой же inode и права доступа.
   ```bash
   vagrant@ubuntu-impish:~$ touch test.txt
   vagrant@ubuntu-impish:~$ ln test.txt hl_test.txt
   vagrant@ubuntu-impish:~$ ll
   -rw-rw-r-- 2 vagrant vagrant       0 Feb  1 18:21 hl_test.txt
   -rw-rw-r-- 2 vagrant vagrant       0 Feb  1 18:21 test.txt
   vagrant@ubuntu-impish:~$ chmod 644 test.txt
   vagrant@ubuntu-impish:~$ ls -li
   437 -rw-r--r-- 2 vagrant vagrant       0 Feb  1 18:21 hl_test.txt
   437 -rw-r--r-- 2 vagrant vagrant       0 Feb  1 18:21 test.txt
   ```

1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

    * ```bash
      vagrant@ubuntu-impish:~$ lsblk
      NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
      loop0    7:0    0 61.9M  1 loop /snap/core20/1270
      loop1    7:1    0 73.7M  1 loop /snap/lxd/22162
      loop2    7:2    0 43.3M  1 loop /snap/snapd/14295
      sda      8:0    0  2.5G  0 disk
      sdb      8:16   0  2.5G  0 disk
      sdc      8:32   0   40G  0 disk
      └─sdc1   8:33   0   40G  0 part /
      sdd      8:48   0   10M  0 disk
      ```

1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo fdisk -l
     Disk /dev/sda: 2.5 GiB, 2684354560 bytes, 5242880 sectors
     Disk model: VBOX HARDDISK
     Units: sectors of 1 * 512 = 512 bytes
     Sector size (logical/physical): 512 bytes / 512 bytes
     I/O size (minimum/optimal): 512 bytes / 512 bytes
     Disklabel type: dos
     Disk identifier: 0x0383b3b9

     Device     Boot   Start     End Sectors  Size Id Type
     /dev/sda1          2048 4196351 4194304    2G 83 Linux
     /dev/sda2       4196352 5242879 1046528  511M 83 Linux
     ```

1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo sfdisk -d /dev/sda | sudo sfdisk /dev/sdb
     Checking that no-one is using this disk right now ... OK

     Disk /dev/sdb: 2.5 GiB, 2684354560 bytes, 5242880 sectors
     Disk model: VBOX HARDDISK
     Units: sectors of 1 * 512 = 512 bytes
     Sector size (logical/physical): 512 bytes / 512 bytes
     I/O size (minimum/optimal): 512 bytes / 512 bytes

     >>> Script header accepted.
     >>> Script header accepted.
     >>> Script header accepted.
     >>> Script header accepted.
     >>> Script header accepted.
     >>> Created a new DOS disklabel with disk identifier 0x0383b3b9.
     /dev/sdb1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
     /dev/sdb2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
     /dev/sdb3: Done.

     New situation:
     Disklabel type: dos
     Disk identifier: 0x0383b3b9

     Device     Boot   Start     End Sectors  Size Id Type
     /dev/sdb1          2048 4196351 4194304    2G 83 Linux
     /dev/sdb2       4196352 5242879 1046528  511M 83 Linux

     The partition table has been altered.
     Calling ioctl() to re-read partition table.
     Syncing disks.
     ```

1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{a1,b1}
     mdadm: Note: this array has metadata at the start and
     may not be suitable as a boot device.  If you plan to
     store '/boot' on this device please ensure that
     your boot-loader understands md/v1.x metadata, or use
     --metadata=0.90
     mdadm: size set to 2094080K
     Continue creating array? y
     mdadm: Defaulting to version 1.2 metadata
     mdadm: array /dev/md0 started.
     ```

1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo mdadm --create --verbose /dev/md1 -l 0 -n 2 /dev/sd{a2,b2}
     mdadm: chunk size defaults to 512K
     mdadm: Defaulting to version 1.2 metadata
     mdadm: array /dev/md1 started.
     vagrant@ubuntu-impish:~$ lsblk
     NAME    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
     loop0     7:0    0 61.9M  1 loop  /snap/core20/1270
     loop1     7:1    0 73.7M  1 loop  /snap/lxd/22162
     loop2     7:2    0 43.3M  1 loop  /snap/snapd/14295
     sda       8:0    0  2.5G  0 disk
     ├─sda1    8:1    0    2G  0 part
     │ └─md0   9:0    0    2G  0 raid1
     └─sda2    8:2    0  511M  0 part
     └─md1   9:1    0 1018M  0 raid0
     sdb       8:16   0  2.5G  0 disk
     ├─sdb1    8:17   0    2G  0 part
     │ └─md0   9:0    0    2G  0 raid1
     └─sdb2    8:18   0  511M  0 part
     └─md1   9:1    0 1018M  0 raid0
     sdc       8:32   0   40G  0 disk
     └─sdc1    8:33   0   40G  0 part  /
     sdd       8:48   0   10M  0 disk
     ```

1. Создайте 2 независимых PV на получившихся md-устройствах.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo pvcreate /dev/md0 /dev/md1
     Physical volume "/dev/md0" successfully created.
     Physical volume "/dev/md1" successfully created.
     ```

1. Создайте общую volume-group на этих двух PV.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo vgcreate vg1 /dev/md0 /dev/md1
     Volume group "vg1" successfully created
     vagrant@ubuntu-impish:~$ sudo vgdisplay
     --- Volume group ---
     VG Name               vg1
     System ID
     Format                lvm2
     Metadata Areas        2
     Metadata Sequence No  1
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                0
     Open LV               0
     Max PV                0
     Cur PV                2
     Act PV                2
     VG Size               <2.99 GiB
     PE Size               4.00 MiB
     Total PE              765
     Alloc PE / Size       0 / 0
     Free  PE / Size       765 / <2.99 GiB
     VG UUID               ihksrT-PiEW-gfcD-GA4g-x8Ff-j5wb-HwmzWb
     ```

1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

   * ```bash
      vagrant@ubuntu-impish:~$ sudo lvcreate -L 100M vg1 /dev/md1
      Logical volume "lvol0" created.
      vagrant@ubuntu-impish:~$ sudo lvdisplay
      --- Logical volume ---
      LV Path                /dev/vg1/lvol0
      LV Name                lvol0
      VG Name                vg1
      LV UUID                dD6WWb-7jM5-LweQ-eh8U-R3Hw-9mDi-fMNkdM
      LV Write Access        read/write
      LV Creation host, time ubuntu-impish, 2022-02-02 12:26:23 +0300
      LV Status              available
      # open                 0
      LV Size                100.00 MiB
      Current LE             25
      Segments               1
      Allocation             inherit
      Read ahead sectors     auto
      -- currently set to    4096
      Block device           253:0
      ```  
1. Создайте `mkfs.ext4` ФС на получившемся LV.

   * ```bash
     vagrant@ubuntu-impish:~$ sudo mkfs.ext4 /dev/vg1/lvol0
     mke2fs 1.46.3 (27-Jul-2021)
     Creating filesystem with 25600 4k blocks and 25600 inodes

     Allocating group tables: done
     Writing inode tables: done
     Creating journal (1024 blocks): done
     Writing superblocks and filesystem accounting information: done
     ```  
1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

   * ```bash
      vagrant@ubuntu-impish:~$ sudo mount /dev/vg1/lvol0 /tmp/new
      vagrant@ubuntu-impish:~$ lsblk
      NAME            MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
      loop0             7:0    0 61.9M  1 loop  /snap/core20/1270
      loop1             7:1    0 61.9M  1 loop  /snap/core20/1328
      loop2             7:2    0 43.4M  1 loop  /snap/snapd/14549
      loop3             7:3    0 76.2M  1 loop  /snap/lxd/22292
      loop5             7:5    0 43.3M  1 loop  /snap/snapd/14295
      loop6             7:6    0 76.2M  1 loop  /snap/lxd/22306
      sda               8:0    0  2.5G  0 disk
      ├─sda1            8:1    0    2G  0 part
      │ └─md0           9:0    0    2G  0 raid1
      └─sda2            8:2    0  511M  0 part
      └─md1           9:1    0 1018M  0 raid0
      └─vg1-lvol0 253:0    0  100M  0 lvm   /tmp/new
      sdb               8:16   0   40G  0 disk
      └─sdb1            8:17   0   40G  0 part  /
      sdc               8:32   0   10M  0 disk
      sdd               8:48   0  2.5G  0 disk
      ├─sdd1            8:49   0    2G  0 part
      │ └─md0           9:0    0    2G  0 raid1
      └─sdd2            8:50   0  511M  0 part
      └─md1           9:1    0 1018M  0 raid0
      └─vg1-lvol0 253:0    0  100M  0 lvm   /tmp/new
     ``` 

1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

1. Прикрепите вывод `lsblk`.

1. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

1. Сделайте `--fail` на устройство в вашем RAID1 md.

1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

1. Погасите тестовый хост, `vagrant destroy`.
