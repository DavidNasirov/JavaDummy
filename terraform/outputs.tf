output "jenkins_url" {
  value = aws_ecs_service.jenkins_service.name
}