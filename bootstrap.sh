#!/bin/sh
npm install
nohup dfx start &
sleep 5
dfx canister create --all
dfx build
dfx canister install --all
