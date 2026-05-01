resource "random_password" "pass" {
  length  = 32
  special = false
}

output "passwd" {
  value = {
    pass = random_password.pass.result,
  }

  sensitive = "true"
}
