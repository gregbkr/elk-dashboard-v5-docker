##################################################################
# HTTP REQUEST : backup, restore and manage indices
##################################################################

----------------------------------------------------
1. SETUP
----------------------------------------------------

*Setup the storage(already done): edit elasticsearch.yml and add the line : path.repo: ["/mount/backup", "/mount/longterm_backup"] --> it have to be a shared/mounted folder between container/host (or ony container)
# for dev: backup on local server: /root/elk/backup/
 
*Declare storage to ES: (if issue, give some right: docker exec elk_elasticsearch_1 chown elasticsearch:elasticsearch /mount/backup/)

# For today and yesterday backup
````
curl -XPUT 'localhost:9200/_snapshot/index_bck' -d '{
    "type": "fs",
    "settings": {
        "location": "/mount/backup/index_bck/",
        "compress": true
    }
}'
```

*check storage:

    curl -POST localhost:9200/_snapshot/index_bck?pretty=1

Physical backup location:
Docker volume: backup:/mount/backup

----------------------------------------------------
2. INDICE
----------------------------------------------------
*Check all indices, or only one:

    curl -XGET localhost:9200/_aliases?pretty=1
    curl -XGET localhost:9200/.kibana?pretty=1

*CLOSE an index:

    curl -XPOST 'localhost:9200/logstash-2015.08.29/_close'

*DELETE an index:

    curl -XDELETE http://localhost:9200/logstash-2015.08.29

*OPEN an index:

    curl -XPOST 'localhost:9200/logstash-2015.08.29/_open'

*Check health & shards

    curl -XGET 'http://localhost:9200/_cluster/health?pretty=true'
    curl -s 'localhost:9200/_cat/shards'
 
*Set no replicat

    curl -XPUT 'localhost:9200/*/_settings' -d ' { "index" : { "number_of_replicas" : 0 } } '
 
*Force shard to be allocated

    curl -XPOST -d '{ "commands" : [ { "allocate" : { "index" : "logstash-2015.11.19", "shard" : 0, "node" : "Ned Leeds" } } ] }' http://localhost:9200/_cluster/reroute?pretty

----------------------------------------------------
3. SNAPSHOT (BACKUP)
----------------------------------------------------

*TAKE SNAPSHOT of ALL indices:

    curl -XPUT "localhost:9200/_snapshot/index_bck/snapshot_1?wait_for_completion=true"

*TAKE SNAPSHOT of ONE indice only:

    curl -XPUT 'localhost:9200/_snapshot/index_bck/snapshot_.kibana' -d '{
    "indices": ".kibana",
    "ignore_unavailable": "true",
    "include_global_state": false
    }'

*CHECK ALL snapshots:

    curl -s -XGET "localhost:9200/_snapshot/index_bck/_all"?pretty=1

*CHECK ONLY ONE snapshot:

    curl -s XGET localhost:9200/_snapshot/index_bck/snapshot_.kibana?pretty=1

*CHECK only one snapshot STATUS or progression:

    curl -s XGET localhost:9200/_snapshot/index_bck/snapshot_.kibana/_status?pretty=1

*DELETE one snapshot:

    curl -X DELETE localhost:9200/_snapshot/index_bck/snapshot_.kibana

----------------------------------------------------
3. RESTORE
----------------------------------------------------
*RESTORE ONE index from snapshot containing ONE index:

    curl -XPOST localhost:9200/_snapshot/index_bck/snapshot_.kibana/_restore
    curl -XPOST "localhost:9200/_snapshot/index_bck/snapshot_.kibana/_restore?pretty=true&wait_for_completion=true"
 
*RESTORE ONE index from snapshot containing SEVERAL indexes:

    curl -XPOST localhost:9200/_snapshot/my_backup/snapshot_05-08-2015/_restore -d '{ "indices": "logstash-2015.08.04" }'

*CHECK restore status:

    curl -XGET "<hostname>:9200/snapshot_.kibana/_recovery?pretty=true"


----------------------------------------------------
3. CURATOR : backup all index, close old one, and delete
----------------------------------------------------
crontab -e 
```
# elk: backup
#00 0 * * * docker run --rm --name curator -v /root/elk/curator:/root/.curator bobrik/curator --config ~/.curator/curator.yml ~/.curator/snapshot-indice.yml | tee --append /root/log/backup-indice.log > /dev/null

# elk: close index
30 0 * * * docker run --rm --name curator -v /root/elk/curator:/root/.curator bobrik/curator --config ~/.curator/curator.yml ~/.curator/close-indice-older60days.yml | tee --append /root/log/close-index.log > /dev/null

# elk: delete undex
50 0 * * * docker run --rm --name curator -v /root/elk/curator:/root/.curator bobrik/curator --config ~/.curator/curator.yml ~/.curator/delete-indice-older60days.yml | tee --append /root/log/delete-index.log > /dev/null
```

----------------------------------------------------
3. CURATOR : restore all index
----------------------------------------------------

    docker run --rm --name curator -v /root/elk/curator:/root/.curator bobrik/curator --config ~/.curator/curator.yml ~/.curator/restore.yml


----------------------------------------------------
3. CURATOR : backup, optimize indices
----------------------------------------------------

Backup through Curator is always incremental. If some other backup exist on the share storage, curator only take the diff.
http://untergeek.com/2014/02/18/curator-managing-your-logstash-and-other-time-series-indices-in-elasticsearch-beyond-delete-and-optimize/
https://github.com/elastic/curator/issues/174#issuecomment-57056621
Carefull your firewall: sudo nano /etc/default/ufw :  DEFAULT_OUTPUT_POLICY="ACCEPT"


Old version:
*Take snapshot (of kibana index)

    docker run --rm bobrik/curator --host 159.8.x.x --port 9200 snapshot --repository index_bck --name new_snap indices --index .kibana

*view snapshots: 

    docker run --rm bobrik/curator --host 159.8.x.x --port 9200 show snapshots --all-snapshots --repository index_shortterm_bck


----------------------------------------------------
3. SCRIPTS for CRON with CURATOR
----------------------------------------------------

### For Dev:

```
# ELASTIC BACKUP
# 1. Backup shorterm every hours
0 * * * * docker run --rm --name curator_short_bck --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_short_bck" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 snapshot --repository index_shortterm_bck indices --all-indices

# 2. Delete old snapshot in shortterm rep every hours
30 0 * * * docker run --rm --name curator_short_del --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_short_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 delete snapshots --repository index_shortterm_bck --older-than 2 --time-unit days

# 3. Daily backup when index is optimized (when 2 days old)
15 0 * * * docker run --rm --name curator_long_bck --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_long_bck" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 snapshot --repository index_longterm_bck indices --older-than 2 --time-unit days --timestring '%Y.%m.%d'

# 4. Daily delete old snapshot from longterm rep
40 0 * * * docker run --rm --name curator_long_del --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_long_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 delete snapshots --repository index_longterm_bck --older-than 7 --time-unit days


# 5. Daily close indices older than x
5 1 * * * docker run --rm --name curator_index_close --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_index_close" bobrik/curator --host 159.8.x.x --port 9200 --timeout 21500 close indices --older-than 8 --time-unit days --timestring %Y.%m.%d

# 6. Daily delete indices older than x
15 1 * * * docker run --rm --name curator_index_del --log-driver=syslog --log-opt syslo
g-address=udp://localhost:5000 --log-opt syslog-tag="curator_index_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 21500 delete indices --older-than 10 --time-unit days --timestring %Y.%m.%d
```

### For Prod:

```
# ELASTIC BACKUP
# 1. Backup shortterm | every hours
0 * * * * docker run --rm --name curator_short_bck --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_short_bck" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 snapshot --repository index_shortterm_bck indices --all-indices

# 2. Delete snapshot (older than 2 days) in shortterm rep
30 0 * * * docker run --rm --name curator_short_del --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_short_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 delete snapshots --repository index_shortterm_bck --older-than 2 --time-unit days

# 3. Backup when index is optimized (when 2 days old)
15 0 * * * docker run --rm --name curator_long_bck --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_long_bck" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 snapshot --repository index_longterm_bck indices --older-than 2 --time-unit days --timestring '%Y.%m.%d'

# 4. Delete snapshot (older than x months) from longterm rep
40 0 * * * docker run --rm --name curator_long_del --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_long_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 600 delete snapshots --repository index_longterm_bck --older-than 13 --time-unit months

# 5. Close indices (older than x months)
5 1 * * * docker run --rm --name curator_index_close --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_index_close" bobrik/curator --host 159.8.x.x --port 9200 --timeout 21500 close indices --older-than 12 --time-unit months --timestring %Y.%m.%d

# 6. Daily delete indices (older than x months)
15 1 * * * docker run --rm --name curator_index_del --log-driver=syslog --log-opt syslog-address=udp://localhost:5000 --log-opt syslog-tag="curator_index_del" bobrik/curator --host 159.8.x.x --port 9200 --timeout 21500 delete indices --older-than 13 --time-unit months --timestring %Y.%m.%d
```

##################################################################
# ELASTICDUMP : Save and restore indices
##################################################################

Export/save all config and kibana index: 

    docker run \
      --rm \
      -v $PWD/kibana-conf:/kibana-conf \
      sherzberg/elasticdump \
        --input=http://192.168.x.x:9200/.kibana \
        --output=$ \
        --type=data \
    > kibana-conf/kibana4-index-export.json

Import: 

    docker run \
      --rm \
      -v $PWD/kibana-conf:/kibana-conf \
      sherzberg/elasticdump \
        --input=/kibana-conf/kibana4-index-export.json \
        --output=http://192.168.x.x:9200/.kibana \
        --type=data
