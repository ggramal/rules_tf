resource "null_resource" "cluster" {
  triggers = {
    password = random_password.pass.result
  }

}

resource "random_password" "pass" {
  length  = 32
  special = false
}
