## An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/linkedup.svg?branch=master)](https://travis-ci.org/dfinity-lab/linkedup?branch=master)

### Prerequisites

- [Docker](https://docker.com)

### Demo

Build and run the container.
```bash
docker build --no-cache --tag dfinity-lab/linkedup .
docker run \
    --publish 8000:8000 \
    --volume `pwd`:/workspace \
    dfinity-lab/linkedup sh bootstrap.sh
```

Open the canister frontend in your web browser.
```bash
ID=$(xxd -u -p canisters/profile/_canister.id)
CRC=$(python2 -c "import crc8;h=crc8.crc8();h.update('$ID'.decode('hex'));print(h.hexdigest())")
xdg-open "http://127.0.0.1:8000/?canisterId=ic:$ID$CRC"
```
