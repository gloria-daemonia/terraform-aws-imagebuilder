output "ami_id" {
  description = "ImageBuilder result AMI"
  value       = data.aws_ami.this.id
}

output "infrastructure_configuration_arn" {
  description = "ImageBuilder Infrastructure Configuration ARN"
  value       = aws_imagebuilder_infrastructure_configuration.this.arn
}

output "distribution_configuration_arn" {
  description = "ImageBuilder Distribution Configuration ARN"
  value       = aws_imagebuilder_distribution_configuration.this.arn
}

output "component_arn" {
  description = "ImageBuilder Component ARN"
  value       = aws_imagebuilder_component.this.arn
}

output "image_recipe_arn" {
  description = "ImageBuilder Image Recipe ARN"
  value       = aws_imagebuilder_image_recipe.this.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name with build logs"
  value       = aws_cloudwatch_log_group.this.name
}

output "imagebuilder_image_arn" {
  description = "ImageBuilder Image ARN"
  value       = aws_imagebuilder_image.this.arn
}
