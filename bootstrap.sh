#!/bin/sh
npm install
nohup dfx start &
sleep 5
dfx build
dfx canister install --all
