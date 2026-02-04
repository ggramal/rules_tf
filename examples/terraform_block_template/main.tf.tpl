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
    path = "./{state_file}.tfstate"
  }
}
