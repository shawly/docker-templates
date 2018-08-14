#!/usr/bin/env bash

bash /entrypoint.sh $@ &
pid="$!"

# SIGTERM-handler
term_handler() {
  if [ $pid -ne 0 ]; then
    /usr/vpnserver/vpnserver stop
    wait "$pid"
  fi
  exit 143; # 128 + 15 -- SIGTERM
}

trap 'term_handler' SIGTERM

# wait indefinitely
while true
do
   tail -f /dev/null & wait ${!}
done
