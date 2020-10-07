# mongo-replset

Mongo container for replica set deployments

## Usage

* Create a docker-compose.yml

```yml

```

* Run `docker-compose up -d`

* Open `http://localhost:8081` for accessing mongo express


## ENVs

* CONFIG_REPLICA_SET - name of the replica set to be used in configsrv replication. defaults to 'configsrv'
* CONFIG_SERVER_NODES - command separated list of config servers. ex.: configsrv1,configsrv2,configsrv3. required
* SHARED_KEY_SECRET - secret name with shared key. defaults to '', which will run with no keyfile
* WIRED_TIGER_CACHE_SIZE_GB - defines the max cache size for wired tiger storage in GB. defaults to 1/2 of available mem limits for this container (defined in limits of cgroup)

## Volumes

* Mount volumes at "/data".
