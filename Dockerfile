FROM alpine:3.11
LABEL maintainer="sawanoboriyu@higanworks.com"
ARG PKGVER=1.5.11
ARG SOURCE=https://openlitespeed.org/packages/openlitespeed-${PKGVER}.src.tgz
ENV PKGVER=$PKGVER

WORKDIR /usr/src
RUN wget -nv https://openlitespeed.org/packages/openlitespeed-${PKGVER}.src.tgz
RUN tar xvzf openlitespeed-${PKGVER}.src.tgz

RUN apk add --update \
  linux-headers \
  openssl-dev \
  geoip-dev \
  expat-dev \
  pcre-dev \
  zlib-dev \
	bsd-compat-headers \
  lua-dev \
  luajit-dev \
  brotli-dev \
  autoconf \
  cmake \
  make \
  gcc \
  g++ \
  zlib-dev \
  pcre-dev \
  git \
  file \
  udns-dev \
  php7-litespeed php7-bcmath php7-json php7-mcrypt php7-session php7-sockets php7-posix

ADD patches/${PKGVER} /usr/src/patches
ADD package.sh /usr/src/package.sh
WORKDIR /usr/src/openlitespeed-${PKGVER}
RUN for x in $(ls ../patches/*.patch) ; do patch -p1 -i $x ; done

# Skipped: --with-lua --with-brotli=/usr/lib/
RUN ./configure \
    --prefix=/var/lib/litespeed \
    --with-user=litespeed \
    --with-group=litespeed \
    --enable-adminssl=no \
    --disable-rpath \
    --disable-static \
    --with-openssl=/usr \
    --with-expat \
    --with-pcre \
    --with-zlib

RUN make && make install

# clean up
RUN addgroup -S litespeed
RUN adduser -S -D -H -h /var/lib/litespeed -s /sbin/nologin -G litespeed -g litespeed litespeed
RUN /usr/src/package.sh

WORKDIR /var/lib/litespeed
EXPOSE 7080 8088
# ENTRYPOINT [ "/usr/sbin/lshttpd", "-v" ]
ENTRYPOINT [ "/var/lib/litespeed/bin/litespeed", "-d" ]
# Commands Reference: https://docs.litespeedtech.com/lsws/commands/
