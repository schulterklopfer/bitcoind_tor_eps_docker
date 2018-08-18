#!/bin/bash

# will always build a container with the latest release of bitcoind and tor support
docker build bitcoind -t bitcoind:latest && \
# will build local openvpn from unchanged kylemanna/openvpn image, in case sth happens to kylemanna/openvpn
docker build openvpn -t openvpn:latest && \
# will build electrum personal server image
docker build electrumPS -t eps:latest