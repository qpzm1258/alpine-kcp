#!/bin/bash

ss-server -s 0.0.0.0 -p 8989 -m aes-256-gcm -k 131415 &

kcpserver -t 127.0.0.1:8989 -l :29900 -mode fast2 -mtu 1400 -key 131415 -crypt none -datashard 0 -parityshard 0 -sndwnd 512 -rcvwnd 2048 --nocomp --quiet &
