### creating an EC2 instance using Terraform

### key pair for SSH access
resource "aws_key_pair" "my-key" {
    key_name   = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")
}

### creating a security group and Vpc 
resource aws_default_vpc default {
}

resource "aws_security_group" "my_security_group" {
  name        = "automate_sg"
  description = "This is a Terraform automated security group"
  vpc_id      = aws_default_vpc.default.id

### inbound rule to allow SSH access
  ingress {
    from_port   = 22
    to_port    = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from anywhere"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access from anywhere"
  }

  ## outbound rule to allow all traffic
  egress {
    from_port = 0 ## 0 means all ports are allowed
    to_port = 0
    protocol = "-1"  ## -1 means all protocols are allowed
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_sg"
  }
}

## ec2 instance creation

resource "aws_instance" "myserver" {
    ami = "ami-0d97d7f07b25dd693"
    instance_type = "t3.micro"
    key_name = aws_key_pair.my-key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    root_block_device {
        volume_size = 8
        volume_type = "gp3"
    }

    tags = {
        Name = "Terra-server"
    }
}