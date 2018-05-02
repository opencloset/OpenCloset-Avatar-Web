FROM registry.theopencloset.net/opencloset/node:latest as builder
MAINTAINER Hyungsuk Hong <aanoaa@gmail.com>

WORKDIR /build

# npm -> bower -> grunt 순서대로
COPY package.json package.json
RUN npm install

COPY .bowerrc .bowerrc
COPY bower.json bower.json
RUN bower --allow-root install

COPY public/assets/coffee/ public/assets/coffee/
COPY public/assets/less/ public/assets/less/
COPY Gruntfile.coffee Gruntfile.coffee
RUN grunt


FROM registry.theopencloset.net/opencloset/perl:latest

RUN groupadd opencloset && useradd -g opencloset opencloset

RUN apt-get update && apt-get install -y libimlib2-dev \
    && apt-get clean

WORKDIR /tmp
COPY cpanfile cpanfile
RUN cpanm --notest \
    --mirror http://www.cpan.org \
    --mirror http://cpan.theopencloset.net \
    --installdeps .

# Everything up to cached.
WORKDIR /home/opencloset/service/avatar.theopencloset.net
COPY --from=builder /build .
COPY . .
RUN mkdir -p public/thumbnails
RUN chown -R opencloset:opencloset .
VOLUME /home/opencloset/service/avatar.theopencloset.net/public/thumbnails

USER opencloset
ENV MOJO_HOME=/home/opencloset/service/avatar.theopencloset.net
ENV MOJO_CONFIG=avatar.conf

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["hypnotoad"]

EXPOSE 5000
