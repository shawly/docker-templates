#!/bin/sh
set -e
set -x

# write environment vars to config.yml
envsubst < /tmp/config.template.yml > /tmp/config.yml

# generate ssh-key
if [ ! -f "/tmp/git-private.key" ]; then
  ssh-keygen -q -t rsa -N '' -f /tmp/git-private.key
fi

exit 0
