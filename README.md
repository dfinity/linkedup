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
dfx canister create --all
dfx build
dfx canister install --all
```

Open the canister frontend in your web browser.

```bash
xdg-open "http://127.0.0.1:8000/?canisterId=$(dfx canister id linkedup_assets)"
```
