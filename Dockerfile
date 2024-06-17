FROM savonet/liquidsoap:v2.2.5
LABEL maintainer="XTRadio Ops <contact@xtradio.org>" \
      version="0.1" \
      description="XTRadio Liquidsoap docker image"

COPY radio.liq /etc/liquidsoap/radio.liq

RUN liquidsoap --check /etc/liquidsoap/radio.liq

ENTRYPOINT [ "liquidsoap", "/etc/liquidsoap/radio.liq" ]
