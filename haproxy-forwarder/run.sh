#!/bin/bash


HAPROXY_CONF=${HAPROXY_CONF:-/haproxy.cfg}

cat > $HAPROXY_CONF <<EOF
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice
  maxconn 4096
  pidfile /var/run/haproxy.pid
  stats socket /var/run/haproxy.stats level admin  
defaults
  log global
  mode http
  option redispatch
  option httplog
  option dontlognull
  option forwardfor
  timeout connect 5000
  timeout client 50000
  timeout server 50000
listen stats 0.0.0.0:1935
  mode http
  stats uri /
EOF

CONFIG_NUMBER=0

while getopts ":L:d" opt; do
  case $opt in
    L)
      case "$OPTARG" in
        *:*:*:*)
          read -sr EXPOSED_HOST EXPOSED_PORT ORIGINAL_HOST ORIGINAL_PORT <<< $(echo "$OPTARG" | tr ":" " ")
          ;;
        *:*:*)
          EXPOSED_HOST='*'
          read -sr EXPOSED_PORT ORIGINAL_HOST ORIGINAL_PORT <<< $(echo "$OPTARG" | tr ":" " ")
          ;;
      esac
      cat >> $HAPROXY_CONF <<EOF

frontend frontend_$CONFIG_NUMBER
  bind $EXPOSED_HOST:$EXPOSED_PORT
  default_backend service_$CONFIG_NUMBER
  mode tcp
  option tcplog    
backend service_$CONFIG_NUMBER
  mode tcp
  balance source
  server HOST_$CONFIG_NUMBER $ORIGINAL_HOST:$ORIGINAL_PORT
EOF
      CONFIG_NUMBER=$[ $CONFIG_NUMBER + 1 ]
      ;;
    d)
      DRY_RUN=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ ! x$DRY_RUN == x1 ]; then
  haproxy -f $HAPROXY_CONF
else
  echo "Dry run, generated config:"
  echo "=========================="
  echo
  cat $HAPROXY_CONF
fi