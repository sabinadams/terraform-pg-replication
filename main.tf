provider "aws" {
  region  = var.region
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}


resource "aws_security_group" "database_security_group" {
  name   = "database security group"
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database security group"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_default_subnet.subnet_az1.id, aws_default_subnet.subnet_az2.id]
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = "pulse-parameter-group"
  family = "postgres14"

  parameter {
    apply_method = "pending-reboot"
    name = "rds.logical_replication"
    value = "1"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "pg-pulse"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14"
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  availability_zone      = data.aws_availability_zones.available.names[0]
  db_name                = var.db_name
  publicly_accessible    = true
  skip_final_snapshot    = true
  apply_immediately      = true
}

resource "null_resource" "db_setup" {
  depends_on = [aws_db_instance.rds_instance]
  triggers = {
    file = filesha1("initial.sql")
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOF
      while read line; do
        echo "$line"
        aws rds-data execute-statement --resource-arn "$DB_ARN" --database  "$DB_NAME" --secret-arn "$SECRET_ARN" --sql "$line"
      done  < <(awk 'BEGIN{RS=";\n"}{gsub(/\n/,""); if(NF>0) {print $0";"}}' initial.sql)
      aws rds reboot-db-instance --db-instance-identifier ${aws_db_instance.rds_instance.identifier}
      echo 'Connection String: `postgresql://${aws_db_instance.rds_instance.username}:${aws_db_instance.rds_instance.password}@${aws_db_instance.rds_instance.address}:${aws_db_instance.rds_instance.port}/${aws_db_instance.rds_instance.db_name}`'
      EOF
    environment = {
      DB_ARN     = aws_db_instance.rds_instance.arn
      DB_NAME    = aws_db_instance.rds_instance.db_name
      SECRET_ARN = aws_secretsmanager_secret.db-pass.arn
    }
  }
}