set -ex

# Enter temporary directory.
pushd /tmp

# Install jq for processing browserstack poll response
sudo apt-get install jq

# Install DFINITY SDK.
version=0.6.6
wget --output-document install-dfx.sh https://sdk.dfinity.org/install.sh
DFX_VERSION=$version bash install-dfx.sh < <(yes Y)
rm install-dfx.sh

echo "::add-path::/home/runner/bin"

# Install Browserstack binary locally
wget -O browserstack.zip https://www.browserstack.com/browserstack-local/BrowserStackLocal-linux-x64.zip
unzip browserstack.zip -d ${HOME}/bin

# Exit temporary directory.
popd
