# Creating EC2 instance for Web Tier 1
resource "aws_instance" "nagesh_web_tier1" {
  ami                         = "ami-0c38b837cd80f13bb" # Amazon Linux 2 AMI
  key_name                    = "kmaster"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet1.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.week18_public_sg_db.id]
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>This is Nagesh Week18 Project Tier 1 </h1></body></html>" > /var/www/html/index.html
        EOF
  tags = {
    Name = "nagesh-EC2-1"
  }
}

# Creating EC2 instance for Web Tier 2
resource "aws_instance" "nagesh_web_tier2" {
  ami                         = "ami-0c38b837cd80f13bb" # Amazon Linux 2 AMI
  key_name                    = "kmaster"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet2.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.week18_public_sg_db.id]
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>This is Nagesh Week18 Project Tier 2 </h1></body></html>" > /var/www/html/index.html
        EOF
  tags = {
    Name = "nagesh-EC2-2"
  }
}
