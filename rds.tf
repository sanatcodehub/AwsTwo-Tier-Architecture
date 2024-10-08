# Creating RDS Database
resource "aws_db_instance" "terraform_database" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.jenkins_terraform_subgroup.id
  vpc_security_group_ids = [aws_security_group.terraform_database_tier_lu.id]
  username               = "username"  # Replace with your username
  password               = "password"  # Replace with your password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  tags = {
    Name = "terraform-RDSDatabase"
  }
}

# Creating private security group for Database tier
resource "aws_security_group" "terraform_database_tier_lu" {
  name        = "terraform_database_tier_lu"
  description = "Allow traffic from SSH & HTTP"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port       = 8279  # You can use 3306 (default), 3307, or 8279
    to_port         = 8279
    protocol        = "tcp"
    cidr_blocks     = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-Database-SG"
  }
}
