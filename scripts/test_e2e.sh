#!/bin/bash

set -ex

if [ -z "$BROWSERSTACK_API_KEY" ]; then
  1>&2 echo "BROWSERSTACK_API_KEY environment variable is required"
  exit 1
fi

BROWSERSTACK_USERNAME=${BROWSERSTACK_USERNAME:=andrewwylde1}

rm -rf .dfx
npm install

dfx start --background
dfx canister create --all
dfx build
dfx canister install --all

CAN_JSON="{\"linkedup_assets\": \"$(dfx canister id linkedup_assets)\"}"

# run e2e
echo $CAN_JSON >cypress/plugins/canister_ids.json
BrowserStackLocal --key $BROWSERSTACK_API_KEY --daemon start

npm install

# Get the build ID from the run command's output
BUILD_ID=$(
  npx browserstack-cypress run --username $BROWSERSTACK_USERNAME --key $BROWSERSTACK_API_KEY |
    grep 'build id:' |
    rev |
    cut -d" " -f1 |
    rev
)

# Poll status every 10 seconds.
POLLING_INTERVAL=10
BUILD_STATUS="running"

while [ $BUILD_STATUS == "running" ]; do
  sleep $POLLING_INTERVAL

  # Get the build status
  BUILD_INFO=$(npx browserstack-cypress build-info $BUILD_ID --username $BROWSERSTACK_USERNAME --key $BROWSERSTACK_API_KEY | tail -n +4)
  echo %
  BUILD_STATUS=$(echo $BUILD_INFO | jq -r '.status')
done

timeout 240s BrowserStackLocal --key $BROWSERSTACK_API_KEY --daemon stop

dfx stop

# count number of devices with failures in their results.
FAILURES=$(echo $BUILD_INFO | jq '.devices | to_entries | map(select(.value.status == "error")) | length')
MAX_FAILURES=0
if [ "$FAILURES" -gt "$MAX_FAILURES" ]; then
  exit 1
else
  exit 0
fi
