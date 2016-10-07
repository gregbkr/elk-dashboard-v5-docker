#!/bin/bash
# enable script execution: sudo chmod +x *.sh

echo "Load elastic Search with logs exemples"

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "Proxy log for GeoIP $NOW"
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 56.42.42.43 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" ""Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 86.217.118.136 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/39.0"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 119.235.235.85 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/39.0"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 86.217.118.136 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.0"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 119.235.235.85 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.1"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 138.224.0.118 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.1"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 149.126.74.176 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.2"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 198.240.216.43 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.0"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 81.22.38.100 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:39.0) Gecko/20100101 Firefox/37.0"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 56.42.42.43 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" ""Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 456fe9ffba31 elk_proxy_1[1]: 185.11.125.49 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" ""Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"'

nc -w0 -u localhost 5000 <<< '<14>'$NOW' 13de3824fd3b elk_proxy_1[1]: 193.5.110.18 - root [29/Aug/2015:20:54:28 +0000] "GET / HTTP/1.1" 401 596 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36" "-"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 13de3824fd3b elk_proxy_1[1]: 138.224.0.118 - admin [29/Aug/2015:20:54:00 +0000] "GET / HTTP/1.1" 401 194 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" "-"'

nc -w0 -u localhost 5000 <<< '<14>'$NOW' 13de3824fd3b elk_proxy_1[1]: 198.240.216.43 - admin [29/Aug/2015:20:54:00 +0000] "GET / HTTP/1.1" 401 194 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" "-"'
nc -w0 -u localhost 5000 <<< '<14>'$NOW' 13de3824fd3b elk_proxy_1[1]: 193.239.220.79 - admin [29/Aug/2015:20:54:00 +0000] "GET / HTTP/1.1" 401 194 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko" "-"'

# nc -w0 -u localhost 5000 <<< '<14>2015-08-31T15:20:00 456fe9ffba31 elk_proxy_1[1]: 56.10.10.10 - - [24/Aug/2015:12:11:36 +0000] "GET /api/doc/schema/currency?Authorization=ApiKey%20userame:apikey HTTP/1.1" 301 5 "http://preprod:8000/api/doc/" ""Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"'
# <14>2015-08-31T11:29:11Z a9459f525220 elk_proxy_1[1]: 172.17.42.1 - sbex [31/Aug/2015:11:29:11 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36" "-"