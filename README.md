## An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/linkedup.svg?branch=master)](https://travis-ci.org/dfinity-lab/linkedup?branch=master)

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/dfinity-lab/linkedup) 

### Demo

Install the required Node modules (only needed the first time).

```bash
npm install
```

Start the replica, then build and install the canisters.

```bash
dfx start --background
dfx build
dfx canister install --all
```

Open the canister frontend in your web browser.

```bash
ID=$(xxd -u -p canisters/linkedup/_canister.id)
CRC=$(python2 -c "import crc8;h=crc8.crc8();h.update('$ID'.decode('hex'));print(h.hexdigest().upper())")
xdg-open "http://127.0.0.1:8000/?canisterId=ic:$ID$CRC"
```
