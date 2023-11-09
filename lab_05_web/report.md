This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        nginx
Server Hostname:        127.0.0.1
Server Port:            8080

Document Path:          /api/v1/cards?limit=20&offset=0&card_set_id=83DD159B-316D-4A30-A765-24B841253A1A&is_learned=true
Document Length:        2 bytes

Concurrency Level:      10
Time taken for tests:   1.389 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      289000 bytes
HTML transferred:       2000 bytes
Requests per second:    719.83 [#/sec] (mean)
Time per request:       13.892 [ms] (mean)
Time per request:       1.389 [ms] (mean, across all concurrent requests)
Transfer rate:          203.15 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.3      0       8
Processing:     1   14  14.1     12     111
Waiting:        1   14  14.1     12     111
Total:          1   14  14.2     12     112

Percentage of the requests served within a certain time (ms)
  50%     12
  66%     18
  75%     21
  80%     24
  90%     32
  95%     40
  98%     57
  99%     62
 100%    112 (longest request)