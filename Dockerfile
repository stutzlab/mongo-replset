FROM mongo:4.4.0-bionic

RUN apt-get update && apt-get install -y netcat inetutils-ping

ENV CONFIG_REPLICA_SET 'replset1'
ENV INIT_REPL_NODES ''
ENV CLUSTER_SHARED_KEY ''
ENV WIRED_TIGER_CACHE_SIZE_GB ''
ENV ROOT_USERNAME 'admin'
ENV ROOT_PASSWORD_SECRET ''

ADD /startup.sh /
ADD /config.sh /
ADD /createuser.sh /

VOLUME [ "/data" ]

EXPOSE 27017

CMD [ "/startup.sh" ]

