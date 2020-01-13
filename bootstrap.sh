#!/bin/sh
npm install
dfx start --background
sleep 5
dfx build
dfx canister install --all
