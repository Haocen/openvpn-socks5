FROM alpine

LABEL org.opencontainers.image.source="https://github.com/Haocen/openvpn-socks"

RUN true \
   && apk add --update-cache openvpn bash openresolv openrc sed curl ip6tables iptables shadow tini tzdata \
   && addgroup -S vpn \
   && rm -rf /var/cache/apk/* \
   && true

RUN set -x \
    # Runtime dependencies.
   && apk add --no-cache \
        linux-pam \
    # Build dependencies.
    && apk add --no-cache -t .build-deps \
        build-base \
        curl \
        linux-pam-dev \
   && cd /tmp \
    # https://www.inet.no/dante/download.html
   && curl -L https://www.inet.no/dante/files/dante-1.4.2.tar.gz | tar xz \
   && cd dante-* \
    # See https://lists.alpinelinux.org/alpine-devel/3932.html
   && ac_cv_func_sched_setscheduler=no ./configure \
   && make install \
   && cd / \
    # Add an unprivileged user.
   && adduser -S -D -u 8062 -H sockd \
    # Install dumb-init (avoid PID 1 issues).
    # https://github.com/Yelp/dumb-init
   && curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
   && chmod +x /usr/local/bin/dumb-init \
    # Clean up.
   && rm -rf /tmp/* \
   && apk del --purge .build-deps

COPY openvpn.sh /usr/bin/
COPY sockd.conf /etc/

ADD start.sh /
RUN chmod +x /start.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=300s --retries=1 \
   CMD curl --fail 'www.baidu.com' || exit 1

VOLUME ["/vpn"]

CMD ["/start.sh"]
ENTRYPOINT ["dumb-init"]