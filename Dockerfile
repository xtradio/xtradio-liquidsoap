FROM ocaml/opam:alpine 

LABEL maintainer="XTRadio Ops <contact@xtradio.org"
LABEL description="XTRadio Liquidsoap build"

USER root

RUN apk update
RUN apk upgrade

# Install packages

RUN apk add libressl-dev \
m4 \
pcre-dev \
file-dev \
pkgconfig \
libmad-dev \
lame-dev

RUN rm -rf /var/cache/apk/*

USER opam

RUN opam update && opam install camlp4 pcre camomile inotify magic base-bytes xmlm camlimages yojson ssl lame mad

WORKDIR /tmp
RUN git clone https://github.com/savonet/liquidsoap-full.git
WORKDIR /tmp/liquidsoap-full

RUN make init && make update

RUN cp PACKAGES.default PACKAGES

RUN ./bootstrap

RUN eval $(opam config env) && ./configure && make clean && make

USER root

RUN make install
