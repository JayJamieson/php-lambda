resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "lambda-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = true
}

resource "aws_api_gateway_resource" "lambda_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "catchall_root" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.catchall_root.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_api.id
  resource_id      = aws_api_gateway_resource.lambda_api_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambda_api_resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method_response.response_200.id,
      aws_api_gateway_integration.lambda_integration_mock_catchall.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda_api_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "production"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.lambda_api_resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.php_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "lambda_integration_mock_catchall" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.catchall_root.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_integration_response" "catchall_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  http_method = aws_api_gateway_method.catchall_root.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.php_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:ap-southeast-2:834849242330:${aws_api_gateway_rest_api.lambda_api.id}/*"
}

resource "aws_api_gateway_usage_plan" "lambda_api_usage" {
  name         = "lambda-api-usage"
  description  = "lambda api usage"
  product_code = "LAMBDA_API"

  api_stages {
    api_id = aws_api_gateway_rest_api.lambda_api.id
    stage  = aws_api_gateway_stage.lambda_api_stage.stage_name
  }

  quota_settings {
    limit  = 10000
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}


resource "aws_api_gateway_api_key" "lambda_api_key" {
  name = "developer"
}

resource "aws_api_gateway_usage_plan_key" "lambda_api_key_usage_plan" {
  key_id        = aws_api_gateway_api_key.lambda_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.lambda_api_usage.id
}

output "api_name" {
  description = "name of api"
  value       = aws_api_gateway_rest_api.lambda_api.name
}

output "lambda_api_resource_url" {
  value = "${aws_api_gateway_deployment.lambda_api_deployment.invoke_url}${aws_api_gateway_stage.lambda_api_stage.stage_name}${aws_api_gateway_resource.lambda_api_resource.path}"
}
