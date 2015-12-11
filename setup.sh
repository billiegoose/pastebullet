#!/bin/bash
DIR=$(dirname $(readlink -f "$BASH_SOURCE"))
cd "$DIR"
mkdir -p config
TMP=$(mktemp -d)
function finish {
  rm -rf "$TMP"
}
trap finish EXIT
# Get the user identity
curl --header "Access-Token: $PBTOKEN" \
     https://api.pushbullet.com/v2/users/me \
| jshon \
| tee config/user.json
# Get system variables
NICKNAME="$(hostname)"
MODEL="$(lsb_release -a 2>/dev/null | grep Description | sed 's/Description:\s*//')"
# Format create device payload
cat template/device.json \
| jshon -s "$NICKNAME" -i nickname \
        -s "$MODEL" -i model \
| tee "$TMP/device.json"
# Create new device
curl --header "Access-Token: $PBTOKEN" \
     --header 'Content-Type: application/json' \
     --data-binary @"$TMP/device.json" \
     --request POST \
     https://api.pushbullet.com/v2/devices \
| jshon \
| tee config/device.json
