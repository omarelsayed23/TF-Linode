terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
  token = var.token
}

resource "linode_stackscript" "juno_stackscript" {

  label = "juno_node"
  description = "Run a juno node"
  is_public = false

  images = ["linode/ubuntu18.04", "linode/ubuntu16.04lts", "linode/ubuntu22.04"]
  rev_note = "initial version"
  script = <<EOF
#!/bin/bash
sudo apt-get update

sudo apt-get install make build-essential git patch zlib1g-dev clang \
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


git clone https://github.com/NethermindEth/juno

echo "Changing directory to ./juno/............."
cd juno

echo "Installing Python Dependencies Requirements............."
pip install -r requirements.txt

echo "Installing Go Dependencies Requirements............."
go get ./...

echo "Installing Juno..........."
make juno

exec $SHELL
EOF
}


resource "linode_instance" "juno_node" {
  image  = "linode/ubuntu22.04"
  label  = "juno"
  region = "us-east"
  type   = "g6-standard-2"
  authorized_keys    = [var.authorized_keys]
  root_pass      = var.root_pass

  stackscript_id = linode_stackscript.juno_stackscript.id
 
}
