# docker-alpine-openlitespeed

Build based directory structure like [aports/litespeed](https://pkgs.alpinelinux.org/package/edge/testing/x86/litespeed).

Origin: https://git.alpinelinux.org/aports/tree/testing/litespeed?h=master


## Usage

```
FROM higanworks/docker-alpine-openlitespeed:1.5.11 AS openlitespeed
RUN /bin/true

FROM alpine:3.11
COPY --from=openlitespeed /etc/passwd /etc/passwd
COPY --from=openlitespeed /etc/group /etc/group
COPY --from=openlitespeed /etc/litespeed /etc/litespeed
COPY --from=openlitespeed /usr/sbin/lshttpd /usr/sbin/lshttpd
COPY --from=openlitespeed /usr/lib/litespeed /usr/lib/litespeed
COPY --from=openlitespeed /var/lib/litespeed /var/lib/litespeed
COPY --from=openlitespeed /var/log/litespeed /var/log/litespeed
RUN apk add php7-litespeed php7-bcmath php7-json php7-mcrypt php7-session php7-sockets php7-posix

...
```