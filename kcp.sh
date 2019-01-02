#!/bin/bash

udpraw -c -l0.0.0.0:8855 -r $SERVER_IP:$UDP2RAW_SERVER_PORT -k "131415" --cipher-mode none --raw-mode faketcp &

kcpclient -r 127.0.0.1:8855 -l :8964 -mode fast2 -mtu 1200 -key 131415 -crypt none -datashard 0 -parityshard 0 -sndwnd 2048 -rcvwnd 2048 -nocomp true -quiet &
