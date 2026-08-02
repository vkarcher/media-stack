#!/bin/sh
LOG=/var/log/scrub/scrub.log
POOL=/pool

echo "=================================================" >> "$LOG"
echo "DEBUT   $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

# -B      : premier plan, pour que cron attende la fin
# -c 3 -n 19 : priorité d'E/S « idle », pour ne pas concurrencer le streaming
#              ni le seed. Un scrub lit TOUT le pool : sans ça, il monopolise
#              la tête du disque pendant des heures.
btrfs scrub start -B -c 3 -n 19 "$POOL" >> "$LOG" 2>&1
RC=$?

echo "FIN     $(date '+%Y-%m-%d %H:%M:%S')  (code $RC)" >> "$LOG"
btrfs scrub status "$POOL" >> "$LOG" 2>&1
btrfs scrub status "$POOL" 2>/dev/null | grep -iE "error summary|total to scrub|duration" > /var/log/scrub/dernier-resultat.txt
echo "" >> "$LOG"
