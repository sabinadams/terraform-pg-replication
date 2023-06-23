
variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}


variable "db_user" {
  default     = "postgres"
  description = "DB user username"
}

variable "db_password" {
  default     = "postgres"
  description = "DB user password"
}

variable "db_name" {
  default     = "pulsedb"
  description = "DB name"
}
