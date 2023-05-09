locals {
  ami_name_prefix = "${var.name}-distr-AMI-"
}

resource "aws_security_group" "egress_all" {
  name        = "Egress-all-ImageBuilder-${var.name}"
  description = "Allow egrees to anywhere"
  vpc_id      = var.vpc_id

  egress {
    description      = "All"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
  }
  tags = merge(
    { "Name" = "Egress-all-sg" },
    var.tags
  )
}

resource "aws_imagebuilder_infrastructure_configuration" "this" {
  name                  = "${var.name}-Infra-Config"
  description           = "${var.name} Infrastructure Configuration"
  instance_profile_name = var.instance_profile_name
  instance_types        = [var.imagebuilder_instance_type]
  subnet_id             = var.subnet_id
  security_group_ids = concat(
    [aws_security_group.egress_all.id],
    var.additional_security_group_ids
  )
  key_pair = var.key_pair_name

  instance_metadata_options {
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
  }
  resource_tags = merge(
    { "Description" = "This resource is created by Image Builder to build ${var.name} AMI" },
    var.tags
  )
  tags = merge(
    { "Name" = "${var.name} Image Builder Infrastructure Configuration" },
    var.tags
  )
}


resource "aws_imagebuilder_distribution_configuration" "this" {
  name        = "${var.name}-Distr-Config"
  description = "${var.name} node distribution configuration"
  distribution {
    region = var.distibution_region
    ami_distribution_configuration {
      name        = "${local.ami_name_prefix}{{imagebuilder:buildDate}}"
      description = "This is ${var.name} ami distribution configuration"
      kms_key_id  = var.kms_key
      ami_tags = merge(
        { "Name" = "${var.name}-AMI" },
        var.tags
      )
    }
  }
  tags = merge(
    { "Name" = "${var.name} Image Builder Distribution Configuration" },
    var.tags
  )
}

resource "aws_imagebuilder_component" "this" {
  name        = "${var.name}-Component"
  description = "Component with instructions to install required software for ${var.name}"
  platform    = "Linux"
  version     = "1.0.0"
  data        = var.image_builder_user_data
  tags = merge(
    { "Name" = "${var.name} Image Component" },
    var.tags
  )
}

resource "aws_imagebuilder_image_recipe" "this" {
  name         = "${var.name}-Image-Recipe"
  description  = "Image recipe with a collection of components to execute for ${var.name} "
  version      = "1.0.0"
  parent_image = var.parent_image
  component {
    component_arn = aws_imagebuilder_component.this.arn
  }
  tags = merge(
    { "Name" = "${var.name} Image Recipe" },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/imagebuilder/${aws_imagebuilder_image_recipe.this.name}"
  retention_in_days = 7
  tags = merge(
    { "Name" = "${var.name} Image Builder Log Group" },
    var.tags
  )
}

resource "aws_imagebuilder_image" "this" {
  depends_on                       = [aws_cloudwatch_log_group.this]
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.this.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.this.arn
  image_recipe_arn                 = aws_imagebuilder_image_recipe.this.arn
  tags = merge(
    { "Name" = "${var.name} Image" },
    var.tags
  )
}

data "aws_ami" "this" {
  depends_on  = [aws_imagebuilder_image.this]
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "name"
    values = ["${local.ami_name_prefix}*"]
  }
}

resource "null_resource" "put_result_ami_to_ssm" {
  count    = var.result_ami_ssm_name == null ? 0 : 1
  triggers = { result_ami_changed = data.aws_ami.this.id }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOF
    aws --region=${var.region} ssm put-parameter \\
      --name "${var.result_ami_ssm_name}" \\
      --value "${data.aws_ami.this.id}" \\
      --overwrite
    EOF
  }
}
