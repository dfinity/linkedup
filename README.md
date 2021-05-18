# LinkedUp - An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/linkedup.svg?branch=master)](https://travis-ci.org/dfinity-lab/linkedup?branch=master)

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/dfinity-lab/linkedup)

The LinkedUp sample application provides a simple implementation of an open professional network that demonstrates how to use **inter-canister calls** within a project.

In the LinkedUp sample application, there are two canisters:

* The `linkedup` canister creates and stores basic profile information for a user, including work experience and educational background.
* The `connectd` canister creates and stores a user's connections.

## Before you begin

Before building the sample application, verify the following:

* You have downloaded and installed the DFINITY Canister SDK as described in [Download and install](https://sdk.dfinity.org/docs/quickstart/local-quickstart.html#download-and-install).
* You have stopped any Internet Computer network processes running on the local computer.

## Demo

1. Clone the `linkedup` repository.

2. Change to the local `linkedup` working directory.

    ```bash
    cd linkedup
    ```

3. Install the required node modules (only needed the first time).

    ```bash
    npm install
    ```

4. Open the `dfx.json` file in a text editor and verify the `dfx` setting has same the version number as the `dfx` executable you have installed.

5. Start the replica.

    ```bash
    dfx start --background
    ```

6. Register unique canister identifiers for the `linkedup` project by running the following command:

    ```bash
    dfx canister create --all
    ```

7. Build the application by running the following command:

    ```bash
    dfx build
    ```

8. Deploy the application on the local network by running the following command:

    ```bash
    dfx canister install --all
    ```

9. Copy the canister identifier for the `linkedup_assets` canister (you can use `dfx canister id linkedup_assets`).

10. Open the `linkedup_assets` canister frontend in your web browser.

    For example, if using the default localhost address and port number, the URL looks similar to this:

    ```bash
    http://localhost:8000/?canisterId=7kncf-oidaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-q
    ```
