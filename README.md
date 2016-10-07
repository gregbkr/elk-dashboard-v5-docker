# RUN SBEX LOGGING INFRA : ELK STACK (+ docker syslog driver)

![Schema_ELK_Infra.png](https://bitbucket.org/sbex/elk/raw/master/Schema_ELK_Infra.png)

THis setup will run elk
- elastic database
- receiving logs parsed by logstash
- Web interface Kibana
- Docker is the main source of logs, but we could send anything to syslog 5000/udp

Prerequisite:
- Linux like OS
- Docker, docker-compose

# 1. Get all files from bitbucket sbex/elk
    git clone https://gregbk@bitbucket.org/sbex/elk.git elk && cd elk

# 4. Run all containers: 
    docker-compose up -d

# 6. Log on kibana to see the result (!HTTPS ONLY! enter the credential sbex/Festi'Neuch2015) and configure the index: tick both boxes and select @timestamp.
https://localhost:5600 via password proxy: sbex/Festi'Neuch2015
https://localhost:5601 directly (this route will be firewall for prod)

First time configuration: if you activate at least one container log, kibana will see an index, you juste have to leave all default and push "create" 
Select the field: VM, container, message and you should see already some parsed logs.

# 7. Import all dashboards and Searches: 
    Setting > Object > Import > /kibana-conf/export_all_vX.json

If some dashboards do not display well, need to wait 5 min for the data to come in, then refresh the field:

    Setting > Indices > [logstash-]YYYY.MM.DD > Reload field list (the double arrow in orange)

Increase Kibana time out:

    docker cp kibana/kibana.yml elk_kibana_1:/opt/kibana/config/kibana.yml

Elasticsearch memory: play with HEAP-size ENV var in docker-compose.yml and docker-compose up -d.

#
#-------------------------- Tests  ----------------------------------


# 7.a. To send a new log to syslog:
    nc -w5 -u localhost 5000 <<< "<14>2015-07-20T17:19:16Z 456fe9ffba31 elk_logstash_1[1]: Error #504# from http request..."  

CAREFULL NETCAT: timeout not working on apt-get install netcat-openbsd
install instead : apt-get install netcat

Or use the script to deploy a batch of logs
    sudo chmod +x kibana-conf/*.sh
    kibana-conf/deploy-fake-logs.sh

# 7.b. Bity.com Health

Command:
    
    nc -w5 -u 185.19.30.228 5000 <<< "`date +%Y-%m-%dT%H:%M:%S` vm:`hostname` service:bity.com.health msg:`curl -Is https://bity.com | head -1`"

In a crontab

    # bity.com health
    */1 * * * * /bin/bash -c 'nc -w5 -u 185.19.30.228 5000 <<< "`date +\%Y-\%m-\%dT\%H:\%M:\%S` vm:`hostname` service:bity.com.health msg:`curl -Is https://bity.com | head -1`"' > /dev/null 2>/dev/null


# 8b. Filebeat --> ELK: collect flat log file

On zeus:

     docker run -d --name filebeat -v $PWD/conf/filebeat.yml:/filebeat.yml:ro -v /var/log/auth.log:/mnt/var/log/auth.log:ro -v /var/log/fail2ban.log:/mnt/var/log/fail2ban.log:ro -v /root/script/perf.log:/mnt/root/script/perf.log:ro --security-opt="no-new-privileges" sbex/filebeat

check with
    docker logs filebeat 


#
#-------------------------- Config  ----------------------------------

# 9. To check your config file, you can run logstash to collect easily input string. Each input you paste in the invite will be process and output on screen by logstash. To setup, please exit all docker-compose and run this container: 
  
    docker run -it --rm --name logstash -p 5001:5000 -p 5001:5000/udp -v $PWD/logstash-conf:/opt/logstash/conf.d logstash:1.5.3  -f /opt/logstash/conf.d/logstash-test.conf
  
And paste log messages like this and check if the output is correct. Make modification to logstash-test.conf and restart logstash container to refresh.

    <14>2015-07-20T17:19:16Z 456fe9ffba31 elk_logstash_1[1]:                     "type" => "syslog",
    <14>2015-07-20T17:19:13Z 456fe9ffba31 elk_logspout_1[1]: 2015/07/20 17:19:13 routing all to syslog://dev.local:5000

#
#-------------------------- Backup and Restore and optimize ----------------------------------

# 10. Index management (backup, restore, optimize)

See file: index-mgmt.md

# 11. From Kibana web interface: Save/Load Dashboard/Search

    Setting > Object > Export > /kibana-conf/export_all_vX.json
    Setting > Object > Import > /kibana-conf/export_all_vX.json
#
#-------------------------- Stop and refresh ----------------------------------
# 11. To stop compose
    docker-compose stop

# 12. To refresh logstash after a modification in the logstash.conf file:
    docker restart elk_logstash_1

