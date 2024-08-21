# Creating a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraformvpc"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "terraform_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform-Internet-Gateway"
  }
}

# Creating Elastic IP Address
resource "aws_eip" "terraform_elastic_ip" {
  domain = "vpc"
}

# Creating NAT Gateway
resource "aws_nat_gateway" "terraform_nat_gateway" {
  allocation_id = aws_eip.terraform_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet2.id
}

# Creating NAT Route
resource "aws_route_table" "terraform_route_two" {
  vpc_id = aws_vpc.week18_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_nat_gateway.id
  }

  tags = {
    Name = "jenkins-terraform-Network-Address-Route"
  }
}

# Creating Public Subnet 1
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet1"
  }
}

# Creating Public Subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-public-subnet2"
  }
}

# Creating Private Subnet 1
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-private-subnet1"
  }
}

# Creating Private Subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "terraform-private-subnet2"
  }
}

# Creating Subnet Group
resource "aws_db_subnet_group" "jenkins_terraform_subgroup" {
  name       = "jenkins-terraform-subgroup"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Name = "jenkins database subnet group"
  }
}

# Creating Route Table Association for Private Subnet 1
resource "aws_route_table_association" "terraform_route_two_1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.terraform_route_two.id
}

# Creating Route Table Association for Private Subnet 2
resource "aws_route_table_association" "terraform_route_two_2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.terraform_route_two.id
}

# Creating Security Group
resource "aws_security_group" "terraform_sg" {
  name        = "terraform-sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Load Balancer
resource "aws_lb" "terraform_lb" {
  name               = "terraform-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups    = [aws_security_group.terraform_sg.id]
}

# Creating Load Balancer Target Group
resource "aws_lb_target_group" "terraform_lb_tg" {
  name     = "terraformtargetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform_vpc.id
}

# Creating Load Balancer Target Group Attachment 1
resource "aws_lb_target_group_attachment" "terraform_target_group1" {
  target_group_arn = aws_lb_target_group.terraform_lb_tg.arn
  target_id        = aws_instance.terraform_web_tier1.id
  port             = 80
}

# Creating Load Balancer Target Group Attachment 2
resource "aws_lb_target_group_attachment" "terraform_target_group2" {
  target_group_arn = aws_lb_target_group.terraform_lb_tg.arn
  target_id        = aws_instance.terraform_web_tier2.id
  port             = 80
}

# Creating Load Balancer Listener
resource "aws_lb_listener" "terraform_listener" {
  load_balancer_arn = aws_lb.terraform_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform_lb_tg.arn
  }
}

# Creating Route Table for Web Tier
resource "aws_route_table" "terraform_web_tier" {
  tags = {
    Name = "terraform-Web-Tier"
  }
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_gateway.id
  }
}

# Creating Route Table Association for Public Subnet 1
resource "aws_route_table_association" "terraform_web_tier1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.terraform_web_tier.id
}

# Creating Route Table Association for Public Subnet 2
resource "aws_route_table_association" "terraform_web_tier2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.terraform_web_tier.id
}

# Creating Route Table for Database Tier
resource "aws_route_table" "terraform_database_tier" {
  tags = {
    Name = "DataBase-Tier"
  }
  vpc_id = aws_vpc.terraform_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_gateway.id
  }
}

# Creating Public Security Group
resource "aws_security_group" "terraform_public_sg_db" {
  name        = "terraform-Public-SG-DB"
  description = "Web and SSH allowed"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



