# VPC (9 Resources)
# module.vpc.aws_vpc.this[0] will be created
# module.vpc.aws_subnet.public[0] will be created
# module.vpc.aws_route_table_association.public[0] will be created
# module.vpc.aws_route_table.public[0] will be created
# module.vpc.aws_route.public_internet_gateway[0] will be created
# module.vpc.aws_internet_gateway.this[0] will be created
# module.vpc.aws_default_security_group.this[0] will be created
# module.vpc.aws_default_route_table.default[0] will be created
# module.vpc.aws_default_network_acl.this[0] will be created
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names
  public_subnets = var.public_subnets
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }

  default_route_table_tags = {
    Name = "jenkins-rt"
  }

  igw_tags = {
    Name = "jenkins-igw"
  }
}

# SG
# module.sg.aws_security_group.this_name_prefix[0] will be created
# module.sg.aws_security_group_rule.egress_with_cidr_blocks[0] will be created
# module.sg.aws_security_group_rule.ingress_with_cidr_blocks[0] will be created
# module.sg.aws_security_group_rule.ingress_with_cidr_blocks[1] will be created
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for jenkins"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP Port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

/*
data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = file("./swap_mem_setting.sh")
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("./jenkins-install.sh")
  }
}
*/

# EC2
module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jekins-Server"

  instance_type = var.instance_type
  key_name      = "aws-jenkins-server"
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.sg.security_group_id]
  associate_public_ip_address = true
  availability_zone = data.aws_availability_zones.azs.names[0]
  #user_data = file("./jenkins-install.sh")
  user_data = join("\n", [
    file("${path.module}/swap_mem_setting.sh"),
    file("${path.module}/jenkins-install.sh")
  ])

  tags = {
    Name = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}
