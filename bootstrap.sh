#!/bin/sh
npm install

echo "dfx start"
nohup dfx start --clean &
# dfx start --background --clean
sleep 5

echo "dfx canister create --all"
dfx canister create --all

echo "dfx build"
dfx build

echo "dfx canister install --all"
dfx canister install --all

# echo "dfx stop"
# dfx stop