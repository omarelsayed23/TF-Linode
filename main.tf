terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
#   token = var.token
  token = "hello"
#     token = ${{ secrets.token }}
}

resource "linode_stackscript" "juno_stackscript" {

  label = "juno_node"
  description = "Run a juno node"
  is_public = false

  images = ["linode/ubuntu18.04", "linode/ubuntu16.04lts", "linode/ubuntu22.04"]
  rev_note = "initial version"
  script = <<EOF
#!/bin/bash
exec >/root/SSout 2>/root/SSerr

sudo apt-get update

# codenoid
# https://gist.github.com/codenoid/4806365032bb4ed62f381d8a76ddb8e6
printf "Checking latest Go version...\n";
LATEST_GO_VERSION="$(curl --silent https://go.dev/VERSION?m=text)";
LATEST_GO_DOWNLOAD_URL="https://golang.org/dl/go1.19.linux-amd64.tar.gz"

printf "cd to home ($USER) directory \n"
cd "/root/"

curl -OJ -L --progress-bar https://golang.org/dl/go1.19.linux-amd64.tar.gz

printf "Extracting file...\n"
tar -xf /root/go1.19.linux-amd64.tar.gz -C /root/

latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"

# Install new Go
echo "Create the skeleton for your local users go directory"
mkdir -p ~/go/{bin,pkg,src}
echo "Setting up GOPATH"
echo "export GOPATH=~/go" >> ~/.profile 
export GOPATH
source ~/.profile
source ~/.bashrc

echo "Setting PATH to include golang binaries"
echo "export PATH='$PATH':/usr/local/go/bin:$GOPATH/bin" >> ~/.profile 
export PATH
source ~/.profile
source ~/.bashrc


echo "Installing dep for dependency management"
go get -u github.com/golang/dep/cmd/dep


printf "You are ready to Go!\n";
go version

sudo apt-get install -y make build-essential git patch zlib1g-dev clang \
  openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev llvm \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev \
  liblzma-dev curl wget zlib1g python-pip libncurses5-dev

rm -rf $HOME/.pyenv
curl https://pyenv.run | bash

export PATH="$HOME/.pyenv/bin:$PATH" >> ~/.bashrc
eval "$(pyenv init --path)" >> ~/.bashrc
eval "$(pyenv virtualenv-init -)" >> ~/.bashrc

source ~/.bashrc 

echo "pyenv installation started............."
pyenv install 3.7.13
pyenv global 3.7.13

cd "/root/"

git clone https://github.com/NethermindEth/juno

echo "Changing directory to ./juno/............."
cd /root/juno

echo "Installing Python Dependencies Requirements............."
pip install -r requirements.txt

echo "Installing Go Dependencies Requirements............."
go get ./...

echo "Installing Juno..........."

cd /root/juno

make juno

./build/juno

EOF
}


resource "linode_instance" "juno_node" {
  image  = "linode/ubuntu22.04"
  label  = "juno"
  region = "us-east"
  type   = "g6-standard-2"
#   authorized_keys    = [var.authorized_keys]
  authorized_keys    = ["hello"]
#   authorized_keys    = [${{ secrets.authorized_keys }}]
#   root_pass      = var.root_pass
  root_pass      = "hello"
#   root_pass      = ${{ secrets.root_pass }}

  stackscript_id = linode_stackscript.juno_stackscript.id
 
}
