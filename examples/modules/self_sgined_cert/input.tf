variable "cn" {
  description = "cert common_name"
  type        = string
}

variable "org" {
  description = "cert organizaion"
  type        = string
}

variable "validity_hours" {
  description = "cert validity period hours"
  type        = number
  default     = 1
}

variable "uses" {
  description = "List of key usages allowed for the issued certificate"
  type        = list(string)
  default = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

variable "pk_algo" {
  description = "private key alogrithm"
  type        = string
  default     = "ED25519"
}
