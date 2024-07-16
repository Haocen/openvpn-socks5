FROM alpine

LABEL org.opencontainers.image.source="https://github.com/Haocen/openvpn-socks"

RUN true \
   && apk add --update-cache openvpn dante-server bash openresolv openrc sed curl ip6tables iptables shadow tini tzdata dumb-init linux-pam \
   && addgroup -S vpn \
   && rm -rf /var/cache/apk/* \
   && true

COPY --chmod=0755 openvpn.sh /usr/bin/
COPY sockd.conf /etc/

COPY --chmod=0755 start.sh /

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=1 \
   CMD curl --fail 'www.baidu.com' || exit 1

VOLUME ["/vpn"]

ENV PORT=1080
ENV TUN_DEVICE=tun0

CMD ["/start.sh"]
ENTRYPOINT ["dumb-init"]