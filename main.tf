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

  images = ["linode/ubuntu18.04", "linode/ubuntu16.04lts", "linode/ubuntu22.04"]
  rev_note = "initial version"
  script = <<EOF
#!/bin/sh
#!/bin/bash
# codenoid
# https://gist.github.com/codenoid/4806365032bb4ed62f381d8a76ddb8e6
mkdir /root/omar
touch /root/test.txt
echo "Script starts"
printf "Checking latest Go version...\n";
LATEST_GO_VERSION="$(curl --silent https://go.dev/VERSION?m=text)";
LATEST_GO_DOWNLOAD_URL="https://golang.org/dl/1.19.linux-amd64.tar.gz "

printf "cd to home ($USER) directory \n"
cd "/home/$USER"

curl -OJ -L --progress-bar https://golang.org/dl/1.19.linux-amd64.tar.gz

printf "Extracting file...\n"
tar -xf 1.19.linux-amd64.tar.gz


latest="$(echo $url | grep -oP 'go[0-9\.]+' | grep -oP '[0-9\.]+' | head -c -2 )"


echo "Create the skeleton for your local users go directory"
mkdir -p ~/go/{bin,pkg,src}
echo "Setting up GOPATH"
echo "export GOPATH=~/go" >> ~/.profile && source ~/.profile
echo "Setting PATH to include golang binaries"
echo "export PATH='$PATH':/usr/local/go/bin:$GOPATH/bin" >> ~/.profile && source ~/.profile
echo "Installing dep for dependency management"
go get -u github.com/golang/dep/cmd/dep


printf "You are ready to Go!\n";
go version
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
