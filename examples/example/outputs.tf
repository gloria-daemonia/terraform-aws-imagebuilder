output "ami_id" {
  description = "ImageBuilder result AMI"
  value       = module.imagebuilder_custom_image.ami_id
}

output "infrastructure_configuration_arn" {
  description = "ImageBuilder Infrastructure Configuration ARN"
  value       = module.imagebuilder_custom_image.infrastructure_configuration_arn
}

output "distribution_configuration_arn" {
  description = "ImageBuilder Distribution Configuration ARN"
  value       = module.imagebuilder_custom_image.distribution_configuration_arn
}

output "component_arn" {
  description = "ImageBuilder Component ARN"
  value       = module.imagebuilder_custom_image.component_arn
}

output "image_recipe_arn" {
  description = "ImageBuilder Image Recipe ARN"
  value       = module.imagebuilder_custom_image.image_recipe_arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name with build logs"
  value       = module.imagebuilder_custom_image.cloudwatch_log_group_name
}

output "imagebuilder_image_arn" {
  description = "ImageBuilder Image ARN"
  value       = module.imagebuilder_custom_image.imagebuilder_image_arn
}
