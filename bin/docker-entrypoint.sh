#!/bin/sh
set -o errexit
set -o nounset

if [ "$1" = "cadvisor" ]; then
  # Create the htpasswd file
  auth_file="/cadvisor.htpasswd"
  htpasswd -bc "$auth_file" "$CADVISOR_USER" "$CADVISOR_PASSWORD"

  # Set arguments for cadvisor
  set -- \
    "cadvisor" \
    "-logtostderr" \
    "-storage_driver_secure" \
    "-storage_driver=influxdb" \
    "-storage_driver_host=$INFLUXDB_HOST:$INFLUXDB_PORT" \
    "-storage_driver_user=$INFLUXDB_USER" \
    "-storage_driver_password=$INFLUXDB_PASSWORD" \
    "-storage_driver_db=$INFLUXDB_DATABASE" \
    "-http_auth_file=$auth_file" \
    "-http_auth_realm=cadvisor"
fi

exec "$@"
