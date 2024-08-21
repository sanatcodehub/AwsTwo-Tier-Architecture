# Creating EC2 instance for Web Tier 1
resource "aws_instance" "terraform_web_tire1" {
  ami                         = "ami-04e49d62cf88738f1" # Amazon Linux 2 AMI
  key_name                    = "kmaster"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet1.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.terraform_public_sg_db.id]
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>This is Hellow form server 1 </h1></body></html>" > /var/www/html/index.html
        EOF
  tags = {
    Name = "Terraform-EC2-1"
  }
}

# Creating EC2 instance for Web Tier 2
resource "aws_instance" "terraform_web_tier2" {
  ami                         = "ami-04e49d62cf88738f1" # Amazon Linux 2 AMI
  key_name                    = "kmaster"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet2.id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.terraform_public_sg_db.id]
  user_data                   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>This is Hellow form server 2 </h1></body></html>" > /var/www/html/index.html
        EOF
  tags = {
    Name = "Terraform-EC2-2"
  }
}
