# DEPENDENCIES #

    $ sudo apt-get install libgd-dev

# DATABASE INITIALIZE #

    # `opencloset-avatar` DB 를 만들고 `opencloset` 계정에 권한 부여
    $ mysql -u root -p -e 'GRANT ALL PRIVILEGES ON `opencloset-avatar`.* TO opencloset@localhost IDENTIFIED by "opencloset";'
    $ mysql -u opencloset -p -e 'CREATE DATABASE `opencloset-avatar` DEFAULT CHARACTER SET utf8;'
    $ mysql -u opencloset -p opencloset-avatar < db/init.sql
