locals {
  name   = "Example-Custom-AMI"
  region = "eu-north-1"
  tags = {
    env = "test-env"
  }
}

provider "aws" {
  region = local.region
}

data "aws_ami" "amazon_linux_2_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name           = local.name
  cidr           = "10.0.0.0/16"
  azs            = data.aws_availability_zones.available.names
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  tags           = local.tags
}

module "imagebuilder_instance_profile" {
  source    = "gloria-daemonia/image-builder-instance-profile/aws"
  version   = "1.0.0"
  role_name = "ImageBuilder-Role-${local.name}"
  tags      = local.tags
}

resource "aws_security_group" "ingress_all" {
  name        = "Ingress-all-${local.name}"
  description = "Allow ingress from anywhere"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "All"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    self             = true
  }
  tags = merge(
    { "Name" = "Ingress-all-sg" },
    local.tags
  )
}

module "imagebuilder_custom_image" {
  source                        = "../../"
  name                          = local.name
  vpc_id                        = module.vpc.vpc_id
  instance_profile_name         = module.imagebuilder_instance_profile.instance_profile_name
  imagebuilder_instance_type    = "t3.micro"
  subnet_id                     = module.vpc.public_subnets[0]
  additional_security_group_ids = [aws_security_group.ingress_all.id]
  distibution_region            = local.region
  image_builder_template        = file("./user_data/imagebuilder_user_data.yaml")
  parent_image                  = data.aws_ami.amazon_linux_2_ami.id
  tags                          = local.tags
}
