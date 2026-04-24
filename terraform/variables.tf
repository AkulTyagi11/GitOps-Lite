variable "aws_region" {
  description = "AWS region where infrastructure will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tags."
  type        = string
  default     = "gitops-lite"
}

variable "instance_type" {
  description = "EC2 instance type for the app server."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name used for SSH access."
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into EC2."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "http_cidr_blocks" {
  description = "CIDR blocks allowed to access app over HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring on EC2 (1-minute metrics, extra cost)."
  type        = bool
  default     = false
}

variable "cpu_alarm_threshold" {
  description = "CPU percentage threshold for high-CPU CloudWatch alarm."
  type        = number
  default     = 70
}
