# OpenCloset-Avatar-Web #

열린옷장 프로필 이미지 서비스

## Version ##

v0.1.1

## Dependencies ##

    $ sudo apt-get install libimlib2-dev
    $ cpanm --installdeps .

## Database Setup ##

    # `opencloset-avatar` DB 를 만들고 `opencloset` 계정에 권한 부여
    $ mysql -u root -p -e 'GRANT ALL PRIVILEGES ON `opencloset-avatar`.* TO opencloset@localhost IDENTIFIED by "xxxxxx";'
    $ mysql -u opencloset -p -e 'CREATE DATABASE `opencloset-avatar` DEFAULT CHARACTER SET utf8;'
    $ mysql -u opencloset -p opencloset-avatar < db/init.sql

## Run ##

    $ cp avatar.conf.sample avatar.conf    # then customize it!
    $ MOJO_CONFIG=avatar.conf morbo -vl 'http://*:5002' ./script/avatar

### How to change default image ###

``` sh
#!/bin/sh
curl \
    -F "token=xxxxxxxxx" \
    -F "key=default" \
    -F "img=@path/to/default.png" \
    https://avatar.theopencloset.net/avatar
```

## API Documentation ##

http://docs.avatar3.apiary.io/
