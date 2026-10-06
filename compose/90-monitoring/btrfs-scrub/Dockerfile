FROM alpine:3.20
RUN apk add --no-cache btrfs-progs tzdata
COPY scrub.sh /usr/local/bin/scrub.sh
RUN chmod +x /usr/local/bin/scrub.sh \
 && echo "0 3 1 * * /usr/local/bin/scrub.sh" > /etc/crontabs/root
# chown au démarrage : un crontab qui n'appartient pas à root est ignoré SANS erreur.
CMD ["sh", "-c", "chown root:root /etc/crontabs/root; chmod 600 /etc/crontabs/root; exec crond -f -l 8"]
