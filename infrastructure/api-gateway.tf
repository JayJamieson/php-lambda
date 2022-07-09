resource "aws_apigatewayv2_api" "lambda_http" {
  name                         = "lambda_http"
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.lambda_http.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_api_integration.id}"
}

resource "aws_apigatewayv2_deployment" "lambda_api_deployment" {
  api_id      = aws_apigatewayv2_route.default.api_id
  description = "Production PHP lambda deployment"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_apigatewayv2_integration.lambda_api_integration,
      aws_apigatewayv2_route.default
    ]))
  }

  depends_on = [
    aws_apigatewayv2_integration.lambda_api_integration,
    aws_apigatewayv2_route.default
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_apigatewayv2_stage" "lambda_api_stage" {
  api_id      = aws_apigatewayv2_api.lambda_http.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_api_integration" {
  api_id                 = aws_apigatewayv2_api.lambda_http.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
  connection_type        = "INTERNET"

  description          = "PHP Lambda"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.php_lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.php_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:ap-southeast-2:834849242330:${aws_apigatewayv2_api.lambda_http.id}/*/$default"
}
