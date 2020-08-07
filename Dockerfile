FROM alpine:3.6

ENV TOR_VERSION "0.4.3.6"
ENV TOR_DOWNLOAD_URL "https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz"


RUN apk update && apk add --update curl libevent-dev build-base \
    python openssl-dev zstd-dev zlib-dev bash \
    && rm -rf /var/cache/apk/*

WORKDIR /torbuild

RUN curl -L $TOR_DOWNLOAD_URL | tar xzf - --strip-components 1
RUN ./configure --prefix=/usr &&  make

FROM alpine:3.6
RUN apk update && apk add --update libevent openssl zstd \
    && rm -rf /var/cache/apk/*
WORKDIR /tor
COPY --from=0 /torbuild/src/app/tor .

# default port to used for incoming Tor connections
# can be changed by changing 'ORPort' in torrc
EXPOSE 9001

# socks proxy port
EXPOSE 9050

COPY torrc.middle .

VOLUME [ "/tordata" ]
ENTRYPOINT [ "/tor/tor" ]
CMD [ "-f", "/tor/torrc.middle" ]
