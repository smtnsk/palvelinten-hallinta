install apache with php:
  pkg.installed:
    - pkgs:
      - apache2
      - libapache2-mod-php
      - mariadb-client
      - mariadb-server

service configuration:
  service.running:
    - name: apache2
    - name: mariadb

default index.php:
  file.managed:
    - name: /var/www/html/index.php
    - source: salt://lamp/index.php
