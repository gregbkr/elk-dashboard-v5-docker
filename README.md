## DEPLOY A LOGGING INFRA : ELK STACK v5

![elkv5.png](https://github.com/gregbkr/elk-dashboard-v5-docker/raw/master/elkv5.PNG)

This setup will run elk
* elasticsearch v5 database
* Logstash v2: receiving and parsing logs <-- tried v5 but it is so slow! unusable...
* Kibana v5: Web interface
* Ngnix Proxy : for SSL + password access
* Docker container is the main source of logs, but we could send anything to syslog 5000/udp
* Filebeat collect files.log and send them to syslog 5001/tcp

Prerequisite:
 - Linux like OS
 - Docker, docker-compose


## 1. Get all files from github
    git clone https://github.com/gregbkr/elk-dashboard-docker elk && cd elk

## 2. Fix
Fix an issue with hungry es v5
    
    sudo sysctl -w vm.max_map_count=262144

make it persistent: 

    nano /etc/sysctl.conf
    vm.max_map_count=262144

## 2. Run all containers for version 5:
    
    docker-compose up -d

(For the old version 2, use: docker-compose -f docker-compose-v2.yml up -d)

and send few logs with nc or socat:

    nc -w0 -u localhost 5000 <<< "TEST1"
    echo "`date +\%Y-\%m-\%dT\%H:\%M:\%S` vm:`hostname` service:.com.health msg:TEST2" | socat -t 0 - UDP:localhost:5000

## 3. Log on kibana to see the result

http://localhost:5601 (direct without proxy)

https://localhost:5600 (!HTTPS ONLY! enter the credentials admin/Kibana05) 

Initialize the index: pressing the green "create" button when log starting to come.


## 4. Import dashboards and Searches: 
    Setting > Object > Import > /kibana-conf/export_vX.json

If some dashboards do not display well, need to wait 2 min for the data to come in, then refresh the fields in order to force ELK to initialize  them now:

    Setting > Indices > [logstash-]YYYY.MM.DD > Reload field list (the circle arrow in orange)

#
#---------------------- Config  -------------------------------

## 5. Logstash

### Validate your config 

You can run logstash to easily collect input string. Each input you paste in the invite will be process and output on screen by logstash. To setup, please run this container: 
  
    docker run -it --rm --name logstash -p 5001:5000 -p 5001:5000/udp -v $PWD/logstash-conf:/opt/logstash/conf.d logstash:2  -f /opt/logstash/conf.d/logstash-test.conf
  
And paste log messages like this and check if the output is correct. Make modification to logstash-test.conf and restart logstash container to refresh.

    <14>2015-08-31T15:20:00 vagrant-ubuntu-trusty-64 docker/proxyelk[870]: 2015/07/20 17:19:13 routing all to syslog://dev.local:5000

If you got the field tags = ParseFailure, means your parsing is wrong somewhere... :-(

### Modify log parsing

You can use https://grokdebug.herokuapp.com/ in order to check a log parsing. 

#
#------ Backup and Restore and optimize ------

## Easy backup and restore via elasticdump

Backup index data to a file :

    docker run --rm -ti -v /root/backup:/data sherzberg/elasticdump --all=true --input=http://ip:9200/ --output=/data/elkexport.json
 
restore

    docker run --rm -ti -v /root/backup:/data sherzberg/elasticdump --bulk=true --input=/data/elkexport.json --output=http://ip:9200/

## Index management (backup, restore, rotate)

More info in file: nano INDEX-MGMT.md

#------ Issues ------

## Logstash v5

Try to use image: logstash:5
And run a 

    docker logs -f elk_logstash_1

You will see that logstashv5 start very slowly (5min sometimes)...

#
#---------------------- Stop and refresh -------------------
## To stop compose
    docker-compose stop

## To refresh logstash after a modification in the logstash.conf file:
    docker restart elk_logstash_1
