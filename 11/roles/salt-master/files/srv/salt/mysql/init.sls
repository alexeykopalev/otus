# /srv/salt/mysql/init.sls

# Установка MySQL Server
mysql_server:
  pkg:
    - installed
    - pkgs:
      - mysql-server
      - python3-PyMySQL
      - mysql

#Установка пустово пароля для mysql
name_root-my_empty.cnf:
  file.managed:
    - names:
      - /root/.my.cnf:
        - source: salt://mysql/templates/root-my_empty.cnf.jinja
        - template: jinja
    - unless: test -f /root/.my.cnf

# Запуск службы MySQL
mysql_service:
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - pkg: mysql_server

# Смена пароля root
mysql_root_password:
  cmd.run:
    - name: 'mysqladmin -u root -p password {{ pillar['mysql']['root_password'] }}'
    - require:
      - service: mysql_service
    - onchanges:
      - file: name_root-my_empty.cnf

#Установка пароля для mysql
/root/.my.cnf: 
  file.managed:
    - source: salt://mysql/templates/root-my.cnf.jinja
    - template: jinja

# Создание базы данных
mysql_create_database:
  cmd.run:
    - name: "mysql -u root -p'{{ pillar['mysql']['root_password'] }}' -e 'CREATE DATABASE IF NOT EXISTS {{ pillar['mysql']['database_name'] }};'"
    - require:
      - cmd: mysql_root_password
    - quiet: True

# Создание пользователя и выдача прав
mysql_create_user:
  cmd.run:
    - name: "mysql -u root -p'{{ pillar['mysql']['root_password'] }}' -e \"CREATE USER IF NOT EXISTS '{{ pillar['mysql']['user']['name'] }}'@'backend1.otushl.local' IDENTIFIED BY '{{ pillar['mysql']['user']['password'] }}'; GRANT ALL PRIVILEGES ON {{ pillar['mysql']['database_name'] }}.* TO '{{ pillar['mysql']['user']['name'] }}'@'backend1.otushl.local'; FLUSH PRIVILEGES;\""
    - require:
      - cmd: mysql_create_database
    - quiet: True

#Настройка firewall nftables

nftables:
  pkg.installed:
    - name: nftables
  service.running:
    - watch:
      - file: /etc/sysconfig/nftables.conf
    - enable: true
    - requre:
      - pkg: nftables

/etc/sysconfig/nftables.conf:
  file.managed:
    - source: salt://mysql/templates/nftables.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0600

...