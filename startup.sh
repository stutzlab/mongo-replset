#!/bin/bash
set -e

SHAREDKEY_FILE="/run/secrets/$SHARED_KEY_SECRET"
if [ "$SHARED_KEY_SECRET" != "" ]; then
    if [ ! -f "$SHAREDKEY_FILE" ]; then
        echo "SHARED_KEY_SECRET was defined but no secret found at $SHAREDKEY_FILE"
        exit 1
    fi
    cp $SHAREDKEY_FILE /sharedkey
    chmod 600 /sharedkey
fi

/config.sh &

#MAX WIRED TIGER CACHE
#https://docs.mongodb.com/manual/reference/program/mongod/#cmdoption-mongod-wiredtigercachesizegb
WC=""
if [ "$WIRED_TIGER_CACHE_SIZE_GB" != "" ]; then
    WC="--wiredTigerCacheSizeGB $WIRED_TIGER_CACHE_SIZE_GB"
fi


echo ">>> Starting Mongo configsrv..."
AE=""
if [ "$SHARED_KEY_SECRET" != "" ]; then
    AE="--keyFile /sharedkey"
fi
set -x
mongod --port 27017 $AE $WC --replSet $CONFIG_REPLICA_SET --bind_ip_all --dbpath /data

