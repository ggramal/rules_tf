terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  backend "local" {
    #You have to create this 
    #file if it doesnt exist
    path = "./this.tfstate"
  }
}
