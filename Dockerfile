FROM alpine

LABEL org.opencontainers.image.source="https://github.com/Haocen/openvpn-socks"

RUN true \
   && apk add --update-cache openvpn dante-server bash openresolv openrc sed curl ip6tables iptables shadow tini tzdata dumb-init linux-pam \
   && addgroup -S vpn \
   && rm -rf /var/cache/apk/* \
   && true

# Add an unprivileged user.
RUN adduser -u 8062 sockd
COPY openvpn.sh /usr/bin/
COPY sockd.conf /etc/

ADD start.sh /
RUN chmod +x /start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=1 \
   CMD curl --fail 'www.baidu.com' || exit 1

VOLUME ["/vpn"]

CMD ["/start.sh"]
ENTRYPOINT ["dumb-init"]