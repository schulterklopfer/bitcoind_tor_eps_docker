#!/bin/bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SETUP_DATA=$PWD

(cd images && ./build.sh) && \
docker run -v $PWD/volumes/openvpn:/etc/openvpn -v $SETUP_DATA:/setup/data -v $PWD/setup/openvpn/scripts:/setup/scripts --log-driver=none --rm -it openvpn:latest /setup/scripts/start.sh && \
docker run -v $PWD/volumes/bitcoind:/bitcoin/.bitcoin -v $SETUP_DATA:/setup/data -v $PWD/setup/bitcoind/scripts:/setup/scripts --log-driver=none --rm -it bitcoind:latest /setup/scripts/start.sh && \
docker run -v $PWD/volumes/electrumPS:/eps -v $SETUP_DATA:/setup/data -v $PWD/setup/electrumPS/scripts:/setup/scripts --log-driver=none --rm -it bitcoind:latest /setup/scripts/start.sh