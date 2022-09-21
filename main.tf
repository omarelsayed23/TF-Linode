terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.27.1"
    }

    aws = {
      source = "hashicorp/aws"
    }



  }
}

provider "linode" {
  #token = var.token
  token = local.my_token
}

provider "aws" {
  region = "us-east-1"
access_key = "$TF_VAR_AWS_ACCESS_KEY_ID"
access_secret = "$TF_VAR_AWS_ACCESS_SECRET_KEY"
}

################ New Part for Secrets ##################

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "linode_creds"
}


locals{
  my_token = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["token"]
  my_root_pass = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["root_pass"]
  my_authorized_keys = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["authorized_keys"]
}



########################################################


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
  authorized_keys    = [local.my_authorized_keys]
  root_pass      = local.my_root_pass

  stackscript_id = linode_stackscript.juno_stackscript.id
  stackscript_data = {
    "run_juno_testnet" = "./build/juno --network 0",
    "run_juno_mainnet" = "./build/juno --network 1"
  }
 
}
