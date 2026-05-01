terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
    }
  }
  backend "local" {
    #You have to create this 
    #file if it doesnt exist
    path = "./this.tfstate"
  }
}
