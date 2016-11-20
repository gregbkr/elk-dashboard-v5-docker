## DEPLOY A LOGGING INFRA : ELK STACK

# WORK IN PROGRESS!!

This setup will run elk
* elasticsearch database
* Logstash : receiving and parsing logs
* Kibana : Web interface
* Ngnix Proxy : for SSL + password access
* Docker is the main source of logs, but we could send anything to syslog 5000/udp
* Filebeat collect files.log and send them to syslog 5001/udp

Prerequisite:
 - Linux like OS
 - Docker, docker-compose


## 1. Get all files from github
    git clone https://github.com/gregbkr/elk-dashboard-docker elk && cd elk

## 2. Run all containers:

    docker-compose up -d

## 3. Log on kibana to see the result

http://localhost:5601 (direct without proxy)
https://localhost:5600 (!HTTPS ONLY! enter the credentials admin/Kibana05) 

Initialize the index: pressing the green "create" button when log starting to come

...

## 7. Import all dashboards and Searches: 
    Setting > Object > Import > /kibana-conf/export_vX.json

If some dashboards do not display well, need to wait 2 min for the data to come in, then refresh the fields in order to force ELK to initialize  them now:

    Setting > Indices > [logstash-]YYYY.MM.DD > Reload field list (the circle arrow in orange)

#
#---------------------- Config  -------------------------------

## 10. Logstash

### Validate your config 

You can run logstash to easily collect input string. Each input you paste in the invite will be process and output on screen by logstash. To setup, please run this container: 
  
    docker run -it --rm --name logstash -p 5001:5000 -p 5001:5000/udp -v $PWD/logstash-conf:/opt/logstash/conf.d logstash:1.5.3  -f /opt/logstash/conf.d/logstash-test.conf
  
And paste log messages like this and check if the output is correct. Make modification to logstash-test.conf and restart logstash container to refresh.

    <14>2015-08-31T15:20:00 vagrant-ubuntu-trusty-64 docker/proxyelk[870]: 2015/07/20 17:19:13 routing all to syslog://dev.local:5000

If you got the field tags = ParseFailure, means your parsing is wrong somewhere... :-(

### Modify log parsing

You can use https://grokdebug.herokuapp.com/ in order to check a log parsing. 

#
#------ Backup and Restore and optimize ------

## 12. Index management (backup, restore, rotate)

Configure backup storage  : (done in initialization step - in our case, backups will go in the $PWD/backup local folder)

    es-conf/backup-init.sh

Edit as you wish (correct with you --host IP) and set cron job for backup, restore, index rotation:

    crontab -l | cat es-conf/backup.crontab | crontab -

You can now monitor the backup via CURATOR dashboard

More info in file: index-mgmt.md

#
#---------------------- Stop and refresh -------------------
## 13. To stop compose
    docker-compose stop

## 14. To refresh logstash after a modification in the logstash.conf file:
    docker restart elk_logstash_1
