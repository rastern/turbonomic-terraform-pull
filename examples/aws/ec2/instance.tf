variable "region" {
  type    = string
  default = "us-east-2"
}
variable "template" {
  type = string
}
variable "whitelist" {
  type = list(string)
}

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "default" {
  name        = "default"
  description = "Allow standard HTTP and HTTPS ports inbound and everything outbound"

  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "buckley" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.default.id
  ]
}
