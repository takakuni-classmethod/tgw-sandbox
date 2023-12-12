############################################
# TGW Virginia
############################################
module "tgw_virginia" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.10.0"

  name = "amazon-q-tgw-virginia"

  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true
  enable_dns_support = true
  share_tgw = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "virginia_01" {
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
  subnet_ids         = module.vpc_virginia_01.private_subnets
  vpc_id             = module.vpc_virginia_01.vpc_id

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

resource "aws_ec2_transit_gateway_vpc_attachment" "virginia_02" {
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
  subnet_ids         = module.vpc_virginia_02.private_subnets
  vpc_id             = module.vpc_virginia_02.vpc_id

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

resource "aws_ec2_transit_gateway_peering_attachment" "virginia" {
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
  peer_region = "ap-northeast-1"
  peer_transit_gateway_id = module.tgw_tokyo.ec2_transit_gateway_id
}

resource "aws_ec2_transit_gateway_route" "default_virginia_tokyo" {

  transit_gateway_route_table_id = module.tgw_virginia.ec2_transit_gateway_association_default_route_table_id
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.virginia.id
  destination_cidr_block = module.vpc_tokyo.vpc_cidr_block
}

resource "aws_route" "private_virginia_01_virginia_02" {
  route_table_id            = module.vpc_virginia_01.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_virginia_02.vpc_cidr_block
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
}
resource "aws_route" "private_virginia_02_virginia_01" {
  route_table_id            = module.vpc_virginia_02.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_virginia_01.vpc_cidr_block
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
}

resource "aws_route" "private_virginia_01_tokyo" {
  route_table_id            = module.vpc_virginia_01.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_tokyo.vpc_cidr_block
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
}
resource "aws_route" "private_virginia_02_tokyo" {
  route_table_id            = module.vpc_virginia_02.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_tokyo.vpc_cidr_block
  transit_gateway_id = module.tgw_virginia.ec2_transit_gateway_id
}

############################################
# TGW Tokyo
############################################
module "tgw_tokyo" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.10.0"
  providers = {
    aws = aws.tokyo
  }

  name = "amazon-q-tgw-tokyo"

  enable_auto_accept_shared_attachments = true
  enable_default_route_table_association = true
  enable_default_route_table_propagation = true
  enable_dns_support = true
  share_tgw = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tokyo" {
  provider = aws.tokyo
  transit_gateway_id = module.tgw_tokyo.ec2_transit_gateway_id
  subnet_ids         = module.vpc_tokyo.private_subnets
  vpc_id             = module.vpc_tokyo.vpc_id

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tokyo" {
  provider = aws.tokyo
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.virginia.id
}

resource "aws_ec2_transit_gateway_route" "default_tokyo_virginia_01" {
  provider = aws.tokyo

  transit_gateway_route_table_id = module.tgw_tokyo.ec2_transit_gateway_association_default_route_table_id
  destination_cidr_block = module.vpc_virginia_01.vpc_cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.virginia.id
}
resource "aws_ec2_transit_gateway_route" "default_tokyo_virginia_02" {
  provider = aws.tokyo

  transit_gateway_route_table_id = module.tgw_tokyo.ec2_transit_gateway_association_default_route_table_id
  destination_cidr_block = module.vpc_virginia_02.vpc_cidr_block
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.virginia.id
}

resource "aws_route" "private_tokyo_virginia_01" {
  provider = aws.tokyo

  route_table_id            = module.vpc_tokyo.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_virginia_01.vpc_cidr_block
  transit_gateway_id = module.tgw_tokyo.ec2_transit_gateway_id
}
resource "aws_route" "private_tokyo_virginia_02" {
  provider = aws.tokyo

  route_table_id            = module.vpc_tokyo.private_route_table_ids[0]
  destination_cidr_block    = module.vpc_virginia_02.vpc_cidr_block
  transit_gateway_id = module.tgw_tokyo.ec2_transit_gateway_id
}