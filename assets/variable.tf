variable "aws_region" {
  type        = string
  default     = "us-west-2"
}

variable "flag_content" {
  description = "The flag to be hidden in the snapshot's /var/log/flag.txt file."
  type        = string
  sensitive   = true
}
