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
  script   = file(var.nodes_script_file)

}
//.build/juno --network 0 //for goerli
//.build/juno --network 1 //for mainint

resource "linode_instance" "juno_node" {
  image  = "linode/ubuntu22.04"
  label  = "juno"
  region = "us-east"
  type   = "g6-standard-2"
  authorized_keys    = [var.authorized_keys]
  root_pass      = var.root_pass

  stackscript_id = linode_stackscript.juno_stackscript.id
  stackscript_data = {
    "run_juno_testnet" = "./build/juno --network 0",
    "run_juno_mainnet" = "./build/juno --network 1"
  }
 
}
