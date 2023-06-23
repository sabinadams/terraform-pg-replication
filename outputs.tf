output "connection_string" {
  description = "Connection String for the RDS instance"
  value       = nonsensitive("postgresql://${aws_db_instance.rds_instance.username}:${aws_db_instance.rds_instance.password}@${aws_db_instance.rds_instance.address}:${aws_db_instance.rds_instance.port}/${aws_db_instance.rds_instance.db_name}")
  sensitive   = false
}