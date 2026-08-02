FROM alpine:3.20
RUN apk add --no-cache btrfs-progs tzdata
COPY scrub.sh /usr/local/bin/scrub.sh
RUN chmod +x /usr/local/bin/scrub.sh \
 && echo "0 3 1 * * /usr/local/bin/scrub.sh" > /etc/crontabs/root
CMD ["crond", "-f", "-l", "8"]
