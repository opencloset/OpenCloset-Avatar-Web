[gravatar](http://gravatar.com/) 를 사용하지 않는 사용자를 위한 열린옷장 프로필 이미지 서비스

# DEPENDENCIES #

    $ sudo apt-get install Imlib2-dev
    $ cpanm --installdeps .

# DATABASE INITIALIZE #

    # `opencloset-avatar` DB 를 만들고 `opencloset` 계정에 권한 부여
    $ mysql -u root -p -e 'GRANT ALL PRIVILEGES ON `opencloset-avatar`.* TO opencloset@localhost IDENTIFIED by "opencloset";'
    $ mysql -u opencloset -p -e 'CREATE DATABASE `opencloset-avatar` DEFAULT CHARACTER SET utf8;'
    $ mysql -u opencloset -p opencloset-avatar < db/init.sql

# RUN #

    $ cp avatar.conf.sample avatar.conf
    # then, edit config file your self

    $ MOJO_CONFIG=avatar.conf morbo -vl 'http://*:5002' ./script/open_closet_avatar_web

## How to change default image ##

``` sh
#!/bin/sh
curl \
    -F "token=xxxxxxxxx" \
    -F "key=default" \
    -F "img=@path/to/default.png" \
    https://avatar.theopencloset.net/avatar
```

# API DOCUMENTATION #

http://docs.avatar3.apiary.io/
