module "vpc" {
  source = "./modules/vpc"
}

module "lambda" {
  source     = "./modules/lambda"
  subnet_ids = module.vpc.subnet_ids
  account_id = data.aws_caller_identity.this.account_id
  vpc_info     = module.vpc.vpc_info
}

# module "api-gw" {
#   source = "./modules/api-gw"
#   lambda_fun = module.lambda.invoke_arn
# }