variable "name" {
  description = "Name of the image."
  type        = string
  default     = "Custom-AMI"
  nullable    = false
}

variable "region" {
  description = "The AWS region name. Example: eu-north-1."
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
  nullable    = false
}

variable "instance_profile_name" {
  description = "Name of the instance profile which will be assumed to the ImageBuilder EC2."
  type        = string
  nullable    = false
}

variable "imagebuilder_instance_type" {
  description = "The EC2 instance type to be used to build the AMI."
  type        = string
  default     = "t3.micro"
  nullable    = false
}

variable "subnet_id" {
  description = "The subnet id in which ImageBuilder instance will be deployed to build the image."
  type        = string
  nullable    = false
}

variable "additional_security_group_ids" {
  description = "A list of SG which will be applied to the ImageBuilder instance. Egress all SG is already applied."
  type        = list(string)
  default     = []
}

variable "key_pair_name" {
  description = "Key pair name to connect to the EC2 instance. Make sure the appropriate security group is added."
  type        = string
  default     = null
}

variable "distibution_region" {
  description = "The AWS region in which AMI will be distributed. Example: eu-north-1."
  type        = string
  nullable    = false
}

variable "kms_key" {
  description = "ARN of the KMS Key to encrypt the distributed AMI."
  type        = string
  default     = null
}

variable "image_builder_user_data" {
  description = "The template path with actions for ImageBuilder Component to perform on your image."
  type        = string
  default     = ""
}

variable "parent_image" {
  description = "Base AMI id for ImageBuilder."
  type        = string
  nullable    = false
}

variable "result_ami_ssm_name" {
  description = "The SSM parameter name to which put result AMI id. Will not update anything if null."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to set on the resources."
  type        = map(string)
  default     = {}
}
