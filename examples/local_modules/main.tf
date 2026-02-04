terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  backend "local" {
    #You have to create this 
    #file if it doesnt exist
    path = "./this.tfstate"
  }
}

module "certs" {
  source   = "../modules/self_sgined_cert/"
  for_each = local.certs

  cn  = each.value.cn
  org = each.value.cn

}
