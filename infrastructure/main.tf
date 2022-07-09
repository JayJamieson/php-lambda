terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "php-lambda-data"
}

resource "aws_lambda_function" "php_lambda" {
  function_name = "php_lambda"

  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "index.php"
  architectures    = ["x86_64"]
  filename         = "function.zip"
  source_code_hash = filebase64sha256("function.zip")
  runtime          = "provided.al2"
  timeout          = 900
  memory_size      = 512
  layers           = ["arn:aws:lambda:ap-southeast-2:209497400698:layer:php-74-fpm:48"]
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.php_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "emails/"
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.php_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "lambda-basic-execution"
  description = "policy to allow basic execution of lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Put*",
          "s3:Get*",
          "s3:List*",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::php-lambda-data/*"
        ]
      },
      {
        Action = ["logs:CreateLogGroup"]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:ap-southeast-2:834849242330:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:ap-southeast-2:834849242330:log-group:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.php_lambda.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.php_lambda.function_name
}
