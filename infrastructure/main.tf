terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.29.0"
    }
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "php-lambda-data"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file  = "../index.php"
  output_path = "function.zip"
}

resource "aws_lambda_function" "php_lambda" {
  function_name = "php_lambda"

  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "index.php"
  architectures    = ["x86_64"]
  filename         = "function.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "provided.al2"
  timeout          = 900
  memory_size      = 512

  // see https://runtimes.bref.sh/
  layers           = ["arn:aws:lambda:ap-southeast-2:534081306603:layer:php-80:63"]
  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment
  ]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.php_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "data/"
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
          "arn:aws:logs:ap-southeast-2:${data.aws_caller_identity.current.account_id}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:ap-southeast-2:${data.aws_caller_identity.current.account_id}:log-group:*"
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
