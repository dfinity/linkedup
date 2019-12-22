## Connect: An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/connect.svg?branch=master)](https://travis-ci.org/dfinity-lab/connect?branch=master)

### Prerequisites

- [Google HTML Compressor](https://code.google.com/archive/p/htmlcompressor)
- [Yahoo CSS Compressor](https://yui.github.io/yuicompressor)
- [Node.js](https://nodejs.org/en)
- [DFINITY SDK](https://sdk.dfinity.org)
- [Nginx](https://nginx.com)
- [Lua Nginx Module](https://openresty.org/en/lua-nginx-module.html)
- [LuaRocks](https://luarocks.org)
  - `hex`
  - `luaossl`
  - `luasocket`
  - `org.conman.cbor`

### Demo

```bash
npm install
dfx start --background
make
make install
make run
```

Open [`https://127.0.0.1:8000`](http://127.0.0.1:8000) in your web browser.
