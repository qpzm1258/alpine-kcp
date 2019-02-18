#!/bin/bash

kcpclient -r $SERVER_IP:$KCP_SERVER_PORT -l :8964 -mode fast2 -mtu 1400 -key 131415 -crypt none -datashard 0 -parityshard 0 -sndwnd 512 -rcvwnd 2048 --nocomp --quiet --conn 2 &
