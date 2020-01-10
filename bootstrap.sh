#!/bin/sh
set -e
npm install
dfx start --background
sleep 5
make
make install
make run
