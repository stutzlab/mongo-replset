#!/bin/bash
set -e

PASSWORD_FILE="/run/secrets/$ROOT_PASSWORD_SECRET"
if [ ! -f $PASSWORD_FILE ]; then
    echo "Password file '$PASSWORD_FILE' not found. ROOT_PASSWORD_SECRET is required and must be bound as a secret"
    exit 1
fi

SHAREDKEY_FILE="/run/secrets/$SHARED_KEY_SECRET"
if [ "$SHARED_KEY_SECRET" != "" ]; then
    if [ ! -f "$SHAREDKEY_FILE" ]; then
        echo "SHARED_KEY_SECRET was defined but no secret found at $SHAREDKEY_FILE"
        exit 1
    fi
    cp $SHAREDKEY_FILE /sharedkey
    chmod 600 /sharedkey
fi

if [ "$REPLICA_SET_NAME" = "" ]; then
    echo "REPLICA_SET_NAME is required"
    exit 2
fi

if [ "$ROOT_USERNAME" = "" ]; then
    echo "ROOT_USERNAME is required"
    exit 2
fi

/config.sh &

#MAX WIRED TIGER CACHE
#https://docs.mongodb.com/manual/reference/program/mongod/#cmdoption-mongod-wiredtigercachesizegb
WC=""
if [ "$WIRED_TIGER_CACHE_SIZE_GB" != "" ]; then
    WC="--wiredTigerCacheSizeGB $WIRED_TIGER_CACHE_SIZE_GB"
fi


echo ">>> Starting Mongo replica..."
AE=""
if [ "$SHARED_KEY_SECRET" != "" ]; then
    AE="--keyFile /sharedkey"
fi
set -x
mongod --port 27017 $AE $WC --replSet $REPLICA_SET_NAME --bind_ip_all --dbpath /data

