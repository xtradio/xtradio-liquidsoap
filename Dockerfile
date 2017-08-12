FROM savonet/liquidsoap-full
LABEL maintainer="XTRadio Ops <contact@xtradio.org>" \
      version="0.1" \
      description="XTRadio Liquidsoap docker image"

RUN apt-get update -y
RUN apt-get clean

RUN useradd radio
RUN su radio

CMD ["/usr/local/bin/liquidsoap", "/home/radio/radio.liq"]