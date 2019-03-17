#!/bin/bash

kcpserver -t $SRC_IP:$SRC_PORT -l :29900 -mode fast2 -mtu 1400 -key 131415 -crypt none -datashard 0 -parityshard 0 -sndwnd 512 -rcvwnd 2048 --nocomp --quiet &
