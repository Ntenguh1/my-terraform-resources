data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nimbusdevops"
    key    = "terraform-state/stage/network/terraform.tfstate"
    region = "us-west-1"
  }
}