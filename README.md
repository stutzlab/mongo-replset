# mongo-replset

Mongo container for replica set deployments

## Usage

* Create a file with password at /sample_password

* Create a file with a shared key at /sample_sharedkey

* Create a docker-compose.yml

```yml
version: '3.5'

services:

  mongo1:
    image: stutzlab/mongo-replset
    environment:
      - INIT_REPL_NODES=mongo1,mongo2,mongo3
      - SHARED_KEY_SECRET=mongo_sharedkey
      - ROOT_PASSWORD_SECRET=root_password
    secrets:
      - mongo_sharedkey
      - root_password
    ports:
      - 27017:27017
    volumes:
      - mongo1:/data

  mongo2:
    image: stutzlab/mongo-replset
    environment:
      - SHARED_KEY_SECRET=mongo_sharedkey
      - ROOT_PASSWORD_SECRET=root_password
    ports:
      - 27018:27017
    secrets:
      - mongo_sharedkey
      - root_password
    volumes:
      - mongo2:/data

  mongo3:
    image: stutzlab/mongo-replset
    environment:
      - SHARED_KEY_SECRET=mongo_sharedkey
      - ROOT_PASSWORD_SECRET=root_password
    ports:
      - 27019:27017
    secrets:
      - mongo_sharedkey
      - root_password
    volumes:
      - mongo3:/data

  mongo-express:
    image: mongo-express:0.54.0
    environment:
      - ME_CONFIG_MONGODB_ENABLE_ADMIN=true
      - ME_CONFIG_MONGODB_SERVER=mongo1,mongo2,mongo3
      - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
      - ME_CONFIG_MONGODB_ADMINPASSWORD_FILE=/run/secrets/root_password
      # - ME_CONFIG_BASICAUTH_USERNAME=admin
      # - ME_CONFIG_BASICAUTH_PASSWORD=123123
    restart: always
    secrets:
      - root_password
    ports:
      - 8081:8081

secrets:
  root_password:
    file: ./sample_password
  mongo_sharedkey:
    file: ./sample_sharedkey

volumes:
  mongo1:
  mongo2:
  mongo3:

```

* Run `docker-compose up -d`

* Open `http://localhost:8081` for accessing mongoexpress


## ENVs

* REPLICA_SET_NAME - name of the replica set to be used. defaults to 'replset1'
* CONFIG_REPL_NODES - comma separated list of replica set servers. ex.: mongo1,mongo2,mongo3. required
* ROOT_USERNAME - name of the 'root' username created during replicaset initial setup. defaults to 'admin'
* ROOT_PASSWORD_SECRET - name of the Docker secret that will contain the password for the root user. required
* SHARED_KEY_SECRET - secret name with shared key. defaults to '', which will run with no keyfile
* WIRED_TIGER_CACHE_SIZE_GB - defines the max cache size for wired tiger storage in GB. defaults to 1/2 of available mem limits for this container (defined in limits of cgroup)

## Volumes

* Mount volumes at "/data".
