FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y bc curl git libssl-dev openjdk-8-jre sudo wget xxd

WORKDIR /tmp

# Install Google HTML Compressor.
RUN wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/htmlcompressor/htmlcompressor-1.5.3.jar
RUN sudo mv htmlcompressor-1.5.3.jar /usr/share/java

# Install Yahoo CSS and JavaScript Compressor.
RUN wget https://github.com/yui/yuicompressor/releases/download/v2.4.8/yuicompressor-2.4.8.jar
RUN sudo mv yuicompressor-2.4.8.jar /usr/share/java

# Install Node.
RUN wget https://deb.nodesource.com/setup_12.x -O install.sh
RUN sudo sh install.sh
RUN sudo apt-get install -y nodejs

# Install DFINITY SDK.
RUN wget https://sdk.dfinity.org/install.sh -O install.sh
RUN yes Y | sh install.sh
ENV PATH /root/bin:${PATH}

# Install Nginx with Lua support.
RUN sudo apt-get install -y nginx libnginx-mod-http-lua

# Install self-signed SSL certificate.
RUN sudo openssl req \
    -days 365 \
    -keyout /etc/ssl/private/connect.key \
    -newkey rsa:2048 \
    -nodes \
    -out /etc/ssl/certs/connect.crt \
    -subj '/C=US/ST=CA/L=San Francisco/O=DFINITY USA Research, LLC/OU=IT/CN=127.0.0.1' \
    -x509
RUN sudo chmod 640 /etc/ssl/private/connect.key
RUN sudo chgrp adm /etc/ssl/private/connect.key

# Install Lua package manager.
RUN sudo apt-get install -y luarocks

# Install Lua packages.
RUN sudo luarocks install hex
RUN sudo luarocks install luaossl
RUN sudo luarocks install luasec
RUN sudo luarocks install org.conman.cbor

# Create workspace directory.
RUN mkdir /workspace
WORKDIR /workspace
