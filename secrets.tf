resource "random_id" "id" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "db-pass" {
  name = "db-pass-${random_id.id.hex}"
}

resource "aws_secretsmanager_secret_version" "db-pass-val" {
  secret_id = aws_secretsmanager_secret.db-pass.id
  secret_string = jsonencode(
    {
      username = aws_db_instance.rds_instance.username
      password = aws_db_instance.rds_instance.password
      engine   = "postgres"
      host     = aws_db_instance.rds_instance.address
    }
  )
}