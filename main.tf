variable private_key_path{
  description = "Path to the SSH private key to be used for authentication"
  default = "~/.ssh/key_pair_aws_1_id_rsa"
}

variable public_key_path{
  description = "Path to the SSH public key to be used for authentication"
  default = "~/.ssh/key_pair_aws_1_id_rsa.pub"
}

resource "aws_key_pair" "aws_1" {
  key_name   = "aws_1"               # key pair name AWS
  public_key = "${file(var.public_key_path)}"
}

provider "aws" {
  region = "eu-central-1"
}

#resource "aws_vpc" "default" {
#  cidr_block = "10.0.0.0/16"
#}

resource "aws_security_group" "terraform_14" {
  name        = "terraform_14"
  description = "Used in the terraform"
  # vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the internet
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ec2_instance_14" {
  ami = "ami-060cde69"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.aws_1.id}"

  vpc_security_group_ids = ["${aws_security_group.terraform_14.id}"]


  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = "${file(var.private_key_path)}"
    # The connection will use the local SSH agent for authentication.
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install openjdk-8-jre-headless",
      #"sudo apt-get -y install openjdk-8-jre",
      # "sudo apt-get -y install nginx",
      # "sudo service nginx start",
      # "sudo mkdir ~/mynewdir",
    ]
  }

}



