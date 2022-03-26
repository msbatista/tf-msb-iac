 #! /bin/bash

 sudo docker run -d --restart unless-stopped -p 8086:8086 \
  -v influxdb2:/var/lib/influxdb2 \
  -v ./ssl/influxdb-selfsigned.crt:/etc/ssl/influxdb-selfsigned.crt
  -v ./ssl/influxdb-selfsigned.key:/etc/ssl/influxdb-selfsigned.key
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=123456789 \
  -e DOCKER_INFLUXDB_INIT_ORG=msb \
  -e DOCKER_INFLUXDB_INIT_BUCKET=msb-bucket \
  -e INFLUXD_TLS_CERT=/etc/ssl/influxdb-selfsigned.crt
  -e INFLUXD_TLS_KEY=/etc/ssl/influxdb-selfsigned.key
  influxdb:2.1
