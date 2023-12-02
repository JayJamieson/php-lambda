variable "aws_route53_zone" {
  type = string
  default = "example.tech."
}

variable "aws_acm_certificate_domain" {
  type = string
  default = "phplambda-api.example.com"
}

variable "aws_api_gateway_domain_name" {
  type = string
  default = "phplambda-api.example.com"
}
