FROM logstash:5
RUN find / -iname logstash-plugin
RUN /usr/share/logstash/bin/logstash-plugin list
RUN /usr/share/logstash/bin/logstash-plugin install logstash-filter-multiline
RUN /usr/share/logstash/bin/logstash-plugin list
