terraform {
  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

# user_data is a bash script that writes the text “Hello, World” into index.xhtml runs a tool called busybox
# (which is installed by default on Ubuntu)to start a web server on port 8080 to serve that file
resource "aws_instance" "app" {
  ami                    = "ami-01c647eace872fc02"
  instance_type          = "t2.micro"
vpc_security_group_ids = [aws_security_group.instance.id]



  tags = {
    Name = "Ubuntu Server 22.04 LTS"
  }

  # The <<-EOF and EOF are Terraform’s heredoc syntax, which allows you to create multiline strings without having to
  # insert \n characters all over the place.
  user_data                   = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.xhtml
              nohup busybox httpd -f -p 8080 &
              EOF
  #force creation of new instance
  user_data_replace_on_change = true

}

# allow the EC2 Instance to receive traffic on port 8080
resource "aws_security_group" "instance" {
  name = "terraform-secGroup-instance"

  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
