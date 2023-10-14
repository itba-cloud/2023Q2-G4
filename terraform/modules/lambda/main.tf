resource "random_pet" "unique_lambda_bucket_name" {
  prefix = "lambda"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.unique_lambda_bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  # TODO: check si falta algo mas
  restrict_public_buckets = true
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
}

resource "aws_security_group" "lambda_sg" {
  name_prefix = "lambda-sg-"
  vpc_id      = var.vpc_id

  // Define ingress rules to allow traffic to your Lambda function
  // For example, allowing SSH (port 22) and HTTP (port 80) access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust this to your specific source IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust this to your specific source IP
  }

  // Define egress rules as needed for your Lambda function
  // For example, allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "hello" {
  function_name = "hello"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  source_code_hash = data.archive_file.lambda_hello.output_base64sha256

  role = local.lab_role
}

resource "aws_cloudwatch_log_group" "hello" {
  name = "/aws/lambda/${aws_lambda_function.hello.function_name}"

  retention_in_days = 14
}

data "archive_file" "lambda_hello" {
  type = "zip"

  source_dir  = "resources/lambda/hello"
  output_path = "resources/lambda/hello.zip"
}

resource "aws_s3_object" "lambda_hello" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello.zip"
  source = data.archive_file.lambda_hello.output_path

  etag = filemd5(data.archive_file.lambda_hello.output_path)
}

resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "hello"
  principal     = "apigateway.amazonaws.com"
  # source_arn    = "${var.api_gw_execution_arn}/*/${aws_api_gateway_method.this.http_method}${aws_api_gateway_resource.this.path_part}"
}