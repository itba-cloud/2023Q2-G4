provider "aws" {
  region = "us-east-1" # TODO: var file ? 

  shared_credentials_files = ["~/.aws/credentials"]
}