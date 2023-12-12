############################################
# IAM Role
############################################
resource "aws_iam_role" "ec2" {
  name = "amazon-q-ec2-role"
  description = "amazon-q-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_managed" {
  role = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "amazon-q-ec2-role"
  role = aws_iam_role.ec2.name
}

############################################
# EC2 AMI
############################################
data "aws_ssm_parameter" "virginia_amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

data "aws_ssm_parameter" "tokyo_amazonlinux_2023" {
  provider = aws.tokyo
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

############################################
# EC2 Virginia 01
############################################
resource "aws_security_group" "virginia_01" {
  name = "amazon-q-virginia-sg"
  description = "amazon-q-virginia-sg"
  vpc_id = module.vpc_virginia_01.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "virginia_01_egress_allow_all" {
  security_group_id = aws_security_group.virginia_01.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "virginia_01_ingress_tokyo" {
  security_group_id = aws_security_group.virginia_01.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_tokyo.vpc_cidr_block
}
resource "aws_vpc_security_group_ingress_rule" "virginia_01_ingress_virginia_02" {
  security_group_id = aws_security_group.virginia_01.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_virginia_02.vpc_cidr_block
}

resource "aws_instance" "virginia_01" {
  instance_type = "t3.medium"
  ami = data.aws_ssm_parameter.virginia_amazonlinux_2023.value
  vpc_security_group_ids = [aws_security_group.virginia_01.id]
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  subnet_id = module.vpc_virginia_01.private_subnets[0]
}

############################################
# EC2 Virginia 02
############################################
resource "aws_security_group" "virginia_02" {
  name = "amazon-q-virginia-sg"
  description = "amazon-q-virginia-sg"
  vpc_id = module.vpc_virginia_02.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "virginia_02_egress_allow_all" {
  security_group_id = aws_security_group.virginia_02.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "virginia_02_ingress_tokyo" {
  security_group_id = aws_security_group.virginia_02.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_tokyo.vpc_cidr_block
}
resource "aws_vpc_security_group_ingress_rule" "virginia_02_ingress_virginia_01" {
  security_group_id = aws_security_group.virginia_02.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_virginia_01.vpc_cidr_block
}

resource "aws_instance" "virginia_02" {
  instance_type = "t3.medium"
  ami = data.aws_ssm_parameter.virginia_amazonlinux_2023.value
  vpc_security_group_ids = [aws_security_group.virginia_02.id]
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  subnet_id = module.vpc_virginia_02.private_subnets[0]
}

############################################
# EC2 Tokyo
############################################
resource "aws_security_group" "tokyo" {
  provider = aws.tokyo

  name = "amazon-q-tokyo-sg"
  description = "amazon-q-tokyo-sg"
  vpc_id = module.vpc_tokyo.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "tokyo_egress_allow_all" {
  provider = aws.tokyo

  security_group_id = aws_security_group.tokyo.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "tokyo_ingress_virginia_01" {
  provider = aws.tokyo

  security_group_id = aws_security_group.tokyo.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_virginia_01.vpc_cidr_block
}
resource "aws_vpc_security_group_ingress_rule" "tokyo_ingress_virginia_02" {
  provider = aws.tokyo

  security_group_id = aws_security_group.tokyo.id
  ip_protocol       = "-1"
  cidr_ipv4         = module.vpc_virginia_02.vpc_cidr_block
}

resource "aws_instance" "tokyo" {
  provider = aws.tokyo
  instance_type = "t3.medium"
  ami = data.aws_ssm_parameter.tokyo_amazonlinux_2023.value
  vpc_security_group_ids = [aws_security_group.tokyo.id]
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  subnet_id = module.vpc_tokyo.private_subnets[0]
}