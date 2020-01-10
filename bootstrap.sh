#!/bin/sh
npm install
dfx start --background
sleep 1
dfx build
dfx canister install --all
