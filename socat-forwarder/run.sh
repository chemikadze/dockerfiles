#!/bin/bash


ARGS=""
NTUNNELS=0

while getopts ":L:d" opt; do
  case $opt in
    L)
      case "$OPTARG" in
        *:*:*)
          read -sr EXPOSED_PORT ORIGINAL_HOST ORIGINAL_PORT <<< $(echo "$OPTARG" | tr ":" " ")
          ARGS="$ARGS TCP4-LISTEN:$EXPOSED_PORT,fork,reuseaddr TCP4:$ORIGINAL_HOST:$ORIGINAL_PORT"
          NTUNNELS=$[ $NTUNNELS + 1 ] 
          ;;
        *)
          echo "unknown arg format. -L PORT:HOST:PORT is supported"
          exit 1
      esac
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
  if [ ! x$NTUNNELS == x0 ]; then
    echo $ARGS | xargs -P $NTUNNELS -n 2 bash -c 'socat $0 $1'
  else
    sleep infinity
  fi
else
  echo "Dry run, generated config:"
  echo "=========================="
  echo
  echo $ARGS | xargs -n 2 bash -c 'echo socat $0 $1'
fi