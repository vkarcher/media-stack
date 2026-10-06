FROM alpine:3.20
ARG VERSION=v0.0.36
RUN apk add --no-cache iptables ip6tables ipset ca-certificates curl tzdata \
 && curl -sSL -o /tmp/b.tgz "https://github.com/crowdsecurity/cs-firewall-bouncer/releases/download/${VERSION}/crowdsec-firewall-bouncer-linux-amd64.tgz" \
 && tar xzf /tmp/b.tgz -C /tmp \
 && find /tmp -type f -name "crowdsec-firewall-bouncer" -exec cp {} /usr/local/bin/ \; \
 && chmod +x /usr/local/bin/crowdsec-firewall-bouncer \
 && rm -rf /tmp/*
CMD ["crowdsec-firewall-bouncer", "-c", "/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml"]
