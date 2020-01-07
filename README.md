## An open professional network.

[![Build Status](https://travis-ci.org/dfinity-lab/linkedup.svg?branch=master)](https://travis-ci.org/dfinity-lab/linkedup?branch=master)

### Prerequisites

- [Docker](https://docker.com)

### Demo

```bash
docker build --tag dfinity-lab/linkedup .
docker run \
    --publish 8000:8000 \
    --rm \
    --volume `pwd`:/workspace \
    dfinity-lab/linkedup \
    sh bootstrap.sh
```

Open [`https://127.0.0.1:8000`](https://127.0.0.1:8000) in your web browser.
