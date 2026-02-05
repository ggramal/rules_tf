resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = var.cn
    organization = var.org
  }

  validity_period_hours = var.validity_hours

  allowed_uses = var.uses
}


resource "tls_private_key" "this" {
  algorithm = var.pk_algo
}
