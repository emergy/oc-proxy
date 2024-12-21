FROM alpine:3.21 AS build

# hadolint ignore=DL3018
RUN apk add --no-cache \
  build-base \
  git \
  libressl-dev \
  linux-headers \
  linux-pam-dev \
  readline-dev \
  zlib-dev

# hadolint ignore=DL3059,DL3003
RUN mkdir -p /build \
  && git clone --depth 1 https://github.com/3proxy/3proxy.git /build/3proxy \
  && cd /build/3proxy \
  && make -f Makefile.Linux


FROM alpine:3.21

# hadolint ignore=DL3018
RUN apk add --no-cache \
  openconnect \
  dnsmasq \
  runit \
  jq \
  && mkdir -p /etc/service/openconnect /etc/service/dnsmasq \
  && mkdir -p /opt/3proxy \
  && ln -s /etc/3proxy /opt/3proxy/cfg


RUN mkdir -p /etc/service/openconnect /etc/service/dnsmasq

COPY openconnect-run /etc/service/openconnect/run
COPY dnsmasq-run /etc/service/dnsmasq/run
COPY 3proxy-run /etc/service/3proxy/run
COPY --from=build /build/3proxy/bin /opt/3proxy/bin

RUN chmod +x /etc/service/openconnect/run \
  && chmod +x /etc/service/dnsmasq/run \
  && chmod +x /etc/service/3proxy/run

CMD ["runsvdir", "/etc/service"]
