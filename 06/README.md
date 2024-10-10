#  Копалев А. С. - Домашняя работа № 6

## Задача
Реализация кластера postgreSQL с помощью patroni.
#### Цель
Перевести БД веб проекта на кластер postgreSQL с ипользованием patroni, etcd/consul/zookeeper и haproxy/pgbouncer.
#### Описание/Пошаговая инструкция выполнения домашнего задания:
Разворачиваем отказоустойчивый кластер PostgreSQL с ипользованием patroni, etcd и haproxy в Proxmox.
Создаем внутри кластера вашу БД для проекта
#### Выполнение
Для развёртки инфраструктуры использовался Ansible.
Через Ansiblem в Proxmox (ansible-playbook create-mv.yml) создаются следующие ресурсы:
- 1 виртуальная машина bast-host с внешним IP-адресом, доступная по SSH, реализующая SSH доступ к остальным виртуалкам
- 3 виртуальные машины для кластера postgreSQL с ипользованием patroni, etcd
- 2 виртуальные машины для бэкенда CMS Joomla
- 1 виртуальная машина с доп. диском для общего хранилища виртуальных машин backend
- 2 виртуальные машины для фронтенда keepalived+haproxy

[create-vms.txt](./files/create-vms.txt)

Через Ansible реализуются 7 ролей:
 - "chrony" - установка и синхронизация времени на всех виртуальных машинах
 - "targetcli" - устанавливает targetcli, создает LUN, прописывает ACL клиентов (переменные зашифрованы через ansible-vault) для использования в качестве общей ФС gfs2 для бэкенд серверах, для хранения статики
 - "iscsi-client" - устанавливает iscsi-клиент, подключает LUN с сервера как блочное устройство 
 - "ha-cluster" - устанавливает pacemaker, pcs, fence agent, lvm2, lvm2-lockd, dlm, gfs2-utils, haproxy. Настраивает кластер, создает необходимые ресурсы, создает кластерную ФС. Настраивает HAProxy для работы с кластером PostgreSQL
 - "pgsql-cluster" - устанавливает кластер PostgreSQL с ипользованием patroni, etcd, создает БД CMS Joomla (переменные зашифрованы через ansible-vault)
 - "loomla" - устанавливает на бэкенд сервера nginx и каталог joomla в директорию на общей ФС, заменяет конфиг nginx
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

- Информация о кластере СУБД (patronictl -c /etc/patroni/patroni.yml list)
  
![](files/pic/5.png)

- Проверяем HAProxy, видим, соединение будет идти на лидера

![](files/pic/6.png)

- Проверяем сосояние кластера ECTD (etcdctl endpoint status --cluster -w=table)

![](files/pic/7.png)

![](files/pic/8.png)

- Проверяем работу БД, добавляем запись в БД через сайт.

![](files/pic/9.png)

- Проверяем репликацию на всех нодах БД

![](files/pic/10.png)

- Выключение виртуалки PostgreSQL - db-srv3

![](files/pic/11.png)

- Сосояние кластера СУБД (patronictl -c /etc/patroni/patroni.yml list) и кластера ETCD (etcdctl endpoint status --cluster -w=table)

![](files/pic/12.png)

- Прверка работы сайта

![](files/pic/13.png)

- Добавим запись в БД

![](files/pic/14.png)

- Проверяем репликацию на 2 оставшихся нодах

![](files/pic/15.png)

- Запускаем выключенную виртуалку проверяем состояние кластера

![](files/pic/16.png)

- Выключение виртуалки-лидера - db-srv1

![](files/pic/17.png)

- Сосояние кластера СУБД (patronictl -c /etc/patroni/patroni.yml list) и кластера ETCD (etcdctl endpoint status --cluster -w=table). Видим что лидер сменился на db-srv2

![](files/pic/18.png)

- Проверяем HAProxy, видим, соединение будет идти на лидера

![](files/pic/19.png)

- Добавим запись в БД

![](files/pic/20.png)

- Проверяем репликацию на 2 оставшихся нодах

![](files/pic/21.png)

- Включаем выключенную виртуалку кластера БД

![](files/pic/22.png)

- Сосояние кластера СУБД (patronictl -c /etc/patroni/patroni.yml list) и кластера ETCD (etcdctl endpoint status --cluster -w=table)

![](files/pic/23.png)

- Проверяем записи в таблице на всех нодах кластера. Убедились, что репликация в полном порядке

![](files/pic/24.png)

- вывод ansible-playbook playboor.yml
  
- [ansible-output.txt](files/ansible-output.txt)

### Для удаления инфраструктуры реализована роль - remove-vm. Запуск командой - ansible-playbook remove-vm.yml

- [remove-vms.txt](files/remove-vms.txt)