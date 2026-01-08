variable "prefix" {
  description = "Common prefix for names"
  default     = "terramino"
}

variable "aws_region" {
  description = "AWS Region to deploy the resources of this module."
  default     = "us-east-1"
}

variable "debug_message" {
  description = "Debug message to display in the web application"
  type        = string
  default     = "Custom message!"
}

