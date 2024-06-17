FROM savonet/liquidsoap:v2.2.5
COPY radio.liq /etc/liquidsoap/radio.liq
RUN liquidsoap --check /etc/liquidsoap/radio.liq

FROM savonet/liquidsoap:v2.2.5-minimal
LABEL org.xtradio.maintainer="XTRadio Ops <contact@xtradio.org>" \
      org.xtradio.liquidsoap.version="v2.2.5" \
      org.xtradio.description="XTRadio Liquidsoap docker image"

COPY --from=0 /etc/liquidsoap/radio.liq /etc/liquidsoap/radio.liq

ENTRYPOINT [ "liquidsoap", "/etc/liquidsoap/radio.liq" ]
