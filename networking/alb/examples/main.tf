provider "aws" {
  region = "us-west-1"
}

module "alb" {
    source = "git::https://github.com/jakefurlong/modules.git//networking/alb"

    alb_name = "developer-test-alb"
    subnet_ids = data.aws_subnet_ids.default.ids
}
