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

  images = ["linode/ubuntu18.04", "linode/ubuntu16.04lts"]
  rev_note = "initial version"
  script = <<EOF
#!/bin/sh
mkdir omar
echo "omar is here"
EOF
}


resource "linode_instance" "juno_node" {
  image  = "linode/ubuntu18.04"
  label  = "juno"
  region = "us-east"
  type   = "g6-standard-2"
  authorized_keys    = [var.authorized_keys]
  root_pass      = var.root_pass

  stackscript_id = linode_stackscript.juno_stackscript.id
 
}
