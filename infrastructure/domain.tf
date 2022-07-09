data "aws_route53_zone" "jaythedeveloper_zone" {
  name = "jaythedeveloper.tech."
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = "phplambda-view.jaythedeveloper.tech"
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.jaythedeveloper_zone.zone_id
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

# resource "aws_api_gateway_domain_name" "domain_name" {
#   domain_name              = "phplambda-view.jaythedeveloper.tech"
#   regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn

#   endpoint_configuration {
#     types = [
#       "REGIONAL",
#     ]
#   }
# }

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = "phplambda-view.jaythedeveloper.tech"
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

# resource "aws_api_gateway_base_path_mapping" "path_mapping" {
#   api_id      = aws_api_gateway_rest_api.lambda_api.id
#   stage_name  = aws_api_gateway_stage.lambda_api_stage.stage_name
#   domain_name = aws_api_gateway_domain_name.domain_name.domain_name
# }


resource "aws_route53_record" "sub_domain" {
  name    = "phplambda-view.jaythedeveloper.tech"
  type    = "A"
  zone_id = data.aws_route53_zone.jaythedeveloper_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# list-hosted-zones

# list-hosted-zones-by-name
