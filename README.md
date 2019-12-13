## Connect: An open professional network.

[![Build Status](https://travis-ci.org/enzoh/connect.svg?branch=master)](https://travis-ci.org/enzoh/connect?branch=master)

### Prerequisites

- Google HTML Compressor
- Yahoo CSS Compressor
- Node.js
- DFINITY SDK
- Nginx with Lua support
- OpenSSL
- Lua packages 
  - `hex`
  - `luaossl`
  - `luasocket`
  - `org.conman.cbor`

### Demo

```bash
dfx start --background
make
make install
make run
```

Open http://127.0.0.1:8000 in your web browser.
