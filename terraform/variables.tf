variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed"
}

variable "jenkins_docker_image" {
  description = "Docker image for Jenkins"
}

variable "subnet_id" {
  description = "Subnet ID for ECS tasks"
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for Jenkins ECS task"
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for Jenkins ECS task"
}