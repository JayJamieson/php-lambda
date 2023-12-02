variable "aws_route53_zone" {
  type = string
  default = "example.tech."
}

variable "aws_acm_certificate_domain" {
  type = string
  default = "phplambda-view.example.com"
}

variable "aws_apigatewayv2_domain_name" {
  type = string
  default = "phplambda-view.example.com"
}
