# Установка Nginx
nginx_install:
  pkg.installed:
    - name: nginx

# Установка PHP и необходимых расширений
php_packages:
  pkg.installed:
    - pkgs:
      - php
      - php-fpm
      - php-mysqlnd
      - php-gd
      - php-mbstring
      - php-xml

replace_user_in_/etc/php-fpm.d/www.conf:
  file.replace:
    - name: /etc/php-fpm.d/www.conf
    - pattern: '^user = apache'
    - repl: 'user = nginx'
    - backup: true

replace_group_in_/etc/php-fpm.d/www.conf:
  file.replace:
    - name: /etc/php-fpm.d/www.conf
    - pattern: '^group = apache'
    - repl: 'group = nginx'
    - backup: true

php_fpm:
  service.running:
    - name: php-fpm
    - enable: True
    - require:
      - pkg: php_packages

# Загрузка и установка WordPress
wordpress_create:
  file.directory:
    - name: {{ pillar['wordpress']['site_root'] }}
    - user: nginx
    - group: nginx
    - mode: 755
    - makedirs: True

wordpress_dwn:
  cmd.run:
    - name: 'wget -O {{ pillar['wordpress']['site_root'] }}/wordpress.tar.gz https://wordpress.org/{{ pillar['wordpress']['wp_version'] }}.tar.gz'
    - creates: {{ pillar['wordpress']['site_root'] }}/wordpress.tar.gz
    - cwd: {{ pillar['wordpress']['site_root'] }}

wordpress_extract:
  cmd.run:
    - name: 'tar -xzf {{ pillar['wordpress']['site_root'] }}/wordpress.tar.gz -C {{ pillar['wordpress']['site_root'] }} --strip-components=1'
    - cwd: {{ pillar['wordpress']['site_root'] }}
    - require:
      - cmd: wordpress_dwn

wordpress_chmod:
  file.directory:
    - name: {{ pillar['wordpress']['site_root'] }}
    - user: nginx
    - group: nginx
    - mode: 755
    - recurse:
      - user
      - group
      - mode

wordpress_config:
  file.managed:
    - name: {{ pillar['wordpress']['site_root'] }}/wp-config.php
    - source: salt://wordpress/templates/wp-config.php.jinja
    - template: jinja
    - user: nginx
    - group: nginx
    - mode: 640

# Настройка Nginx для WordPress
nginx_config:
  file.managed:
    - name: /etc/nginx/conf.d/wordpress.conf
    - source: salt://wordpress/templates/nginx.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: nginx_install

restart_nginx:
  service.running:
    - name: nginx
    - reload: True
    - enable: True
    - require:
      - file: nginx_config

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
    - source: salt://wordpress/templates/nftables.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 0600