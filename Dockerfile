FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y acl bc curl git libssl-dev openjdk-8-jre sudo wget xxd

WORKDIR /tmp

# Create development group and user.
RUN groupadd developer
RUN useradd -d /home/developer -g developer -m developer
RUN echo developer ALL=NOPASSWD:ALL > /etc/sudoers.d/developer
RUN chmod 440 /etc/sudoers.d/developer
USER developer

# Install Google HTML Compressor.
RUN wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/htmlcompressor/htmlcompressor-1.5.3.jar
RUN sudo install htmlcompressor-1.5.3.jar /usr/share/java

# Install Yahoo CSS and JavaScript Compressor.
RUN wget https://github.com/yui/yuicompressor/releases/download/v2.4.8/yuicompressor-2.4.8.jar
RUN sudo install yuicompressor-2.4.8.jar /usr/share/java

# Install Node.
RUN wget https://deb.nodesource.com/setup_12.x -O install.sh
RUN sudo sh install.sh
RUN sudo apt-get install -y nodejs

# Install DFINITY SDK.
RUN wget https://sdk.dfinity.org/install.sh -O install.sh
RUN yes Y | sh install.sh
ENV PATH /home/developer/bin:${PATH}

# Install Nginx with Lua support.
RUN sudo apt-get install -y nginx libnginx-mod-http-lua
RUN sudo chown developer /var/log/nginx/error.log
RUN sudo bash -c 'mkdir /var/lib/nginx/{body,fastcgi,proxy,scgi,uwsgi}'

# Install self-signed SSL certificate.
RUN openssl req \
    -days 365 \
    -keyout linkedup.key \
    -newkey rsa:2048 \
    -nodes \
    -out linkedup.crt \
    -subj '/C=US/ST=CA/L=San Francisco/O=DFINITY USA Research, LLC/OU=IT/CN=127.0.0.1' \
    -x509
RUN sudo chmod 755 /etc/ssl/private
RUN sudo install linkedup.crt /etc/ssl/certs
RUN sudo install linkedup.key /etc/ssl/private

# Install Lua package manager.
RUN sudo apt-get install -y luarocks

# Install Lua packages.
RUN sudo luarocks install hex
RUN sudo luarocks install luaossl
RUN sudo luarocks install luasec
RUN sudo luarocks install org.conman.cbor

# Create workspace directory.
RUN sudo mkdir /workspace
RUN sudo chown developer:developer /workspace
WORKDIR /workspace
