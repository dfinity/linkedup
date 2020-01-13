FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y sudo wget

WORKDIR /tmp

# Create development group and user.
RUN groupadd developer
RUN useradd -d /home/developer -g developer -m developer
RUN echo developer ALL=NOPASSWD:ALL > /etc/sudoers.d/developer
RUN chmod 440 /etc/sudoers.d/developer
USER developer

# Install Node.
RUN wget https://deb.nodesource.com/setup_12.x -O /tmp/install-node.sh
RUN sudo sh /tmp/install-node.sh
RUN sudo apt-get install -y nodejs

# Install DFINITY SDK.
RUN wget https://sdk.dfinity.org/install.sh -O /tmp/install-sdk.sh
RUN DFX_VERSION=0.4.12 sh -c 'yes Y | sh /tmp/install-sdk.sh'
ENV PATH /home/developer/bin:${PATH}

# Create workspace directory.
RUN sudo mkdir /workspace
RUN sudo chown developer:developer /workspace
WORKDIR /workspace
