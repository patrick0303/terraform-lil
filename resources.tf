resource "aws_vpc" "environment-example-two" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "terraform-aws-vpc-example-two"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = "${aws_vpc.environment-example-two.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,3 ,1)}"
  availability_zone = "us-east-1a"
}

# Outcome 10.0.32.0/19
# cidrsubnet(iprange, newbits, netnum)
# required bitmask = original bitmask /16 + newbits 3 = /19

# Original: 10.0.0.0/16
# Expected: 10.0.32.0/19, it would be (32) ÷ (2 power (24 - 19)) = (32) ÷ (32) = 1

resource "aws_subnet" "subnet2" {
  vpc_id            = "${aws_vpc.environment-example-two.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,2 ,2 )}"
  availability_zone = "us-east-1b"
}

# Outcome 10.0.128.0/18
# cidrsubnet(iprange, newbits, netnum)
# required bitmask = original bitmask /16 + newbits 2 = /18

# Original: 10.0.0.0/16
# Expected: 10.0.128.0/18, it would be (128) ÷ (2 power (24 - 18)) = (128) ÷ (64) = 2

resource "aws_security_group" "subnetsecurity" {
  vpc_id = "${aws_vpc.environment-example-two.id}"

  ingress {
    cidr_blocks = [
      "${aws_vpc.environment-example-two.cidr_block}",
    ]

    from_port = 80
    protocol  = "tcp"
    to_port   = 80
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "secondserver" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags {
    Name = "pat"
  }

  subnet_id = "${aws_subnet.subnet2.id}"
}
