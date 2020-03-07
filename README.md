## An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/linkedup.svg?branch=master)](https://travis-ci.org/dfinity-lab/linkedup?branch=master)

### Prerequisites

You have downloaded and installed the SDK as described in [Getting started](https://sdk.dfinity.org/developers-guide/getting-started.html).

### Demo

1. Clone the repository.

1. Install `node.js` modules by running the following command (only needed the first time):

    ```bash
    npm install
    ```
1. Start a local internet computer.

    ```bash
    dfx start
    ```

1. Open a new terminal, then execute the following commands:

    ```bash
    dfx build
    dfx canister install --all
    ```
    
1. Open a web browser and navigate to the URL for the canister frontend by specifying the host, port number, and canister identifier for the profile canister.

    For example, if using the default host and port number and the `dfx canister install` command returns:

    ```bash
    Installing code for canister profile, with canister_id ic:5173CDC10071D7DC0B
    ```

    You would use the following URL:

    ```bash
    http://localhost:8000/?canisterId=ic:5173CDC10071D7DC0B
    ```