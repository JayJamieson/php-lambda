data "aws_route53_zone" "root_zone" {
  name = var.aws_route53_zone
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.aws_acm_certificate_domain
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.root_zone.zone_id
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = var.aws_apigatewayv2_domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.certificate.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  depends_on = [
    aws_acm_certificate.certificate
  ]
}

resource "aws_apigatewayv2_api_mapping" "path_mapping" {
  api_id      = aws_apigatewayv2_api.lambda_http.id
  domain_name = aws_apigatewayv2_domain_name.domain_name.id
  stage       = aws_apigatewayv2_stage.lambda_api_stage.id
}

resource "aws_route53_record" "sub_domain" {
  name    = var.aws_apigatewayv2_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.root_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
