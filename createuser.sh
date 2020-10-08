#!/bin/sh

echo "ROOT USER CREATION"

if [ "$ROOT_PASSWORD_SECRET" != "" ]; then

    PASSWORD_FILE="/run/secrets/$ROOT_PASSWORD_SECRET"

    echo "Waiting for replicaset to be ready..."
    while true; do
        mongo mongodb://localhost --eval "db.isMaster()" | grep $REPLICA_SET_NAME
        if [ "$?" = "0" ]; then
            echo "Replicaset ready. Verifying PRIMARY election"

            #this will work if no other nodes has already added a user password
            mongo --eval "rs.status()" | grep PRIMARY
            if [ "$?" = "0" ]; then
                echo "PRIMARY node is present in this replicaset"
                break
            fi

            #this will verify if any other node has already created and user. exit if so
            mongo --eval "rs.status()" | grep Unauthorized
            if [ "$?" = "0" ]; then
                echo "Replicaset already protected by other node. Skipping user creation"
                exit
            fi
        fi
        sleep 1
        echo "[user]"
    done

    mongo --eval "db.isMaster().ismaster" | grep true
    if [ "$?" = "0" ]; then
        echo "This node is master"

        tee "/createuser.js" > /dev/null <<EOT
        use admin
        db.createUser( { user: "$ROOT_USERNAME",
                        pwd: "$(cat $PASSWORD_FILE)",
                        roles: [ { role: "root", db: "admin" }, { role: "userAdminAnyDatabase", db: "admin" }, { role: "clusterAdmin", db: "admin" } ] 
                        }
                    )
EOT
        set +e
        echo "Creating user '$ROOT_USERNAME'..."
        echo /createuser.js
        mongo < /createuser.js
        set +e
        if [ "$?" = "0" ]; then
            echo "ROOT USER CREATED"
        else
            echo "ROOT USER NOT CREATED. IGNORING"
        fi
    else
        echo "This node is secundary. User creation aborted."
    fi
fi