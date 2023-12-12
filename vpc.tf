############################################
# VPC Virginia
############################################
module "vpc_virginia_01" {
  source = "terraform-aws-modules/vpc/aws"

  name = "virginia-01-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_default_security_group" "vpc_virginia_01" {
  vpc_id = module.vpc_virginia_01.vpc_id
}

module "vpc_virginia_02" {
  source = "terraform-aws-modules/vpc/aws"

  name = "virginia-02-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a"]
  private_subnets = ["10.1.1.0/24"]
  public_subnets  = ["10.1.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_default_security_group" "virginia_02" {
  vpc_id = module.vpc_virginia_02.vpc_id
}

############################################
# VPC Tokyo
############################################
module "vpc_tokyo" {
  providers = {
    aws = aws.tokyo
  }

  source = "terraform-aws-modules/vpc/aws"

  name = "tokyo-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["ap-northeast-1a"]
  private_subnets = ["10.10.1.0/24"]
  public_subnets  = ["10.10.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
}

resource "aws_default_security_group" "tokyo" {
  provider = aws.tokyo
  vpc_id = module.vpc_tokyo.vpc_id
}