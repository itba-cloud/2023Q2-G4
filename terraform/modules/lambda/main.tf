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
  vpc_id      = var.vpc_info.vpc_id

  // Define ingress rules to allow traffic to your Lambda function
  // For example, allowing SSH (port 22) and HTTP (port 80) access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_info.vpc_cidr] # Adjust this to your specific source IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_info.vpc_cidr] # Adjust this to your specific source IP
  }

  // Define egress rules as needed for your Lambda function
  // For example, allowing all outbound traffic
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1" # All protocols
  #   cidr_blocks = ["var.vpc_info.vpc_cidr"]
  # }
}

data "archive_file" "lambda_zips" {
  for_each = local.lambda_functions

  type = "zip"
  source_file  = each.value.source_code_file
  output_path = format("%s/%s.zip", local.zip_target_dir, each.value.function_name) 
}

resource "aws_s3_object" "lambda_objects" {
  for_each = local.lambda_functions

  bucket = aws_s3_bucket.lambda_bucket.id

  key    = each.value.function_name
  source = format("%s/%s.zip", local.zip_target_dir, each.value.function_name) 

  etag = filemd5(format("%s/%s.zip", local.zip_target_dir, each.value.function_name) )
}

resource "aws_lambda_function" "lambda_functions" {
  for_each = local.lambda_functions

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  role = local.lab_role

  function_name = each.value.function_name
  s3_key    =  each.value.function_name
  runtime = each.value.runtime
  handler = each.value.handler
  source_code_hash = data.archive_file.lambda_zips[each.key].output_base64sha256

  // Should we move this to the local? 
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}