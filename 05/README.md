#  Копалев А. С. - Домашняя работа № 3

## Задача
Развернуть InnoDB или PXC кластер
#### Цель
Перевести базу веб-проекта на один из вариантов кластера MySQL: Percona XtraDB Cluster или InnoDB Cluster.
#### Описание/Пошаговая инструкция выполнения домашнего задания:
Разворачиваем отказоустойчивый кластер MySQL (PXC || Innodb) на ВМ или в докере любым способом
Создаем внутри кластера вашу БД для проекта
#### Выполнение
Для развёртки инфраструктуры использовался Ansible.
Через Ansiblem в Proxmox (ansible-playbook create-mv.yml) создаются следующие ресурсы:
- 1 виртуальная машина bast-host с внешним IP-адресом, доступная по SSH, реализующая SSH доступ к остальным виртуалкам
- 3 виртуальные машина для Percona XtraDB Cluster
- 2 виртуальные машины для бэкенда Wordpress + ProxySQL
- 1 виртуальная машина с доп. диском для общего хранилища виртуальных машин backend
- 2 виртуальные машины для фронтенда keepalived+haproxy

[create-vms.txt](./files/create-vms.txt)

Через Ansible реализуются 7 ролей:
 - "chrony" - установка и синхронизация времени на всех виртуальных машинах
 - "targetcli" - устанавливает targetcli, создает LUN, прописывает ACL клиентов (переменные зашифрованы через ansible-vault) для использования в качестве общей ФС gfs2 для бэкенд серверах, для хранения статики
 - "iscsi-client" - устанавливает iscsi-клиент, подключает LUN с сервера как блочное устройство 
 - "ha-cluster" - станавливает pacemaker, pcs, fence agent, lvm2, lvm2-lockd, dlm,gfs2-utils. Настраивает кластер, создает необходимые ресурсы, создает кластерную ФС.
 - "db" - устанавливает кластер MySQL: Percona XtraDB Cluster, задает пароль root, создает БД Wordpress, пользователей и пароли для подключения ProxySQL (переменные зашифрованы через ansible-vault)
 - "proxysql" - устанавливает ProxySQL на бэкенд сервера для подключения к кластеру ДБ, задает пароль admin, создает пользователей и пароли для подключния Wordpress (переменные зашифрованы через ansible-vault)
 - "wordpress" - устанавливает на бэкенд сервера nginx и каталог wordpress в директорию но общей ФС, заменяет их конфиги
 - "keepalived" - - устанавливает на фронтенд сервера HAProxy и Keepalived для плавающего IP

[playbook.yml](./playbook.yml)

## Скриншоты из Proxmox, созданного сайта, выводы при выполнении ansible-playbook playbook.yml

- созданные виртуальные машины в Proxmox
  
![](files/pic/1.png)

- Заканчиваем установку Wordpress
  
![](files/pic/2.png)

- Работа админки сайта
  
![](files/pic/3.png)

- Работа сайта
  
![](files/pic/4.png)

- Информация о кластере СУБД (SHOW STATUS LIKE 'wsrep%';)
  
![](files/pic/5.png)

- Проверяем сосояние кластера MySQL через ProxySQL

![](files/pic/6.png)

- Проверяем работу БД, добавляем запись в БД через сайт.

![](files/pic/7.png)

- Проверяем репликацию на всех нодах БД

![](files/pic/8.png)

- Выключение виртуалки MySQL - db-srv1

![](files/pic/9.png)

- Сосояние кластера MySQL

![](files/pic/10.png)

- Прверка работы сайта

![](files/pic/11.png)

- Добавим запись в БД

![](files/pic/12.png)

- Проверяем репликацию на 2 оставшихся нодах

![](files/pic/13.png)

- Запускаем выключенную виртуалку проверяем состояние кластера

![](files/pic/14.png)

- Выключение виртуалоки MySQL - db-srv3

![](files/pic/15.png)

- Сосояние кластера СУБД (SHOW STATUS LIKE 'wsrep%';)

![](files/pic/16.png)

- Состояние виртуалок в Proxmox

![](files/pic/17.png)

- Добавим запись в БД

![](files/pic/18.png)

- Проверяем репликацию на 2 оставшихся нодах

![](files/pic/19.png)

- Включаем выключенную виртуалку кластера БД

![](files/pic/20.png)

- Сосояние кластера СУБД (SHOW STATUS LIKE 'wsrep%';)

![](files/pic/21.png)

- Проверяем записи в таблице на всех нодах кластера

![](files/pic/22.png)

- вывод ansible-playbook playboor.yml
  
- [ansible-output.txt](files/ansible-output.txt)

### Для удаления инфраструктуры реализована роль - remove-vm. Запуск командой - ansible-playbook remove-vm.yml

- [remove-vms.txt](files/remove-vms.txt)