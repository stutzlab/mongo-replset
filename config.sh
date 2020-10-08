#!/bin/bash

set -e

echo "Waiting for mongo server to be available at 27017..."
while ! nc -z 127.0.0.1 27017; do sleep 0.5; done
echo "Mongo OK"
sleep 1

MAX_RETRIES=9999
if [ "$INIT_REPL_NODES" != "" ]; then
   MAX_RETRIES=5
fi

/createuser.sh &

echo "Verifying if this node is already part of a config replicaset..."
C=0
set +e
while (( "$C" < "$MAX_RETRIES" )); do
   mongo mongodb://localhost --eval "db.isMaster()" | grep $REPLICA_SET_NAME
   if [ "$?" = "0" ]; then
     mongo mongodb://localhost --eval "db.isMaster()"
     echo ">>> THIS NODE IS PART OF A CONFIG REPLICASET"
     exit 0
   fi
   echo "."
   if [ "$MAX_RETRIES" != "9999" ]; then
     C=($C+1)
   fi
   sleep 1
   echo "[config]"
done

if [ "$INIT_REPL_NODES" == "" ]; then
  echo ">>> THIS NODE IS NOT PART OF A CONFIG. ADD IT IN ORDER TO BE ACTIVE"
  echo "Tip: On master node, execute rs.add( { host: \"[host]\", priority: 0, votes: 0 } )"
  exit 0
fi

echo "Generating config"
echo ""

rm /init-configserver.js
cat <<EOT >> /init-configserver.js
rs.initiate(
   {
EOT

echo "_id: \"$REPLICA_SET_NAME\"," >> /init-configserver.js

cat <<EOT >> /init-configserver.js
      version: 1,
      members: [
EOT

IFS=',' read -r -a NODES <<< "$INIT_REPL_NODES"
S=""
c=0
for N in "${NODES[@]}"; do
   echo ">>> Node $N"
   echo "${S}{ _id: $c, host : \"$N:27017\" }" >> /init-configserver.js
   S=","
   c=$((c+1))
   echo " - Waiting for host $N to be available..."
   until ping -c1 $N >/dev/null; do sleep 2; done
   # echo " - Host available. Waiting port 27017..."
   # while ! nc -z $N 27017; do sleep 1; done
   echo " - Host $N OK"
done

cat <<EOT >> /init-configserver.js
      ]
   }
)
EOT

echo "/init-configserver.js"
cat /init-configserver.js

echo "CONFIGURING SERVER..."
mongo < /init-configserver.js
echo ">>> SERVER INITIALIZED SUCCESSFULLY"
