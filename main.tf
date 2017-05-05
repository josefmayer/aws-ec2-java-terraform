variable private_key_path{
  description = "Path to the SSH private key to be used for authentication"
  default = "~/.ssh/key_pair_aws_1_id_rsa"
}

variable public_key_path{
  description = "Path to the SSH public key to be used for authentication"
  default = "~/.ssh/key_pair_aws_1_id_rsa.pub"
}

resource "aws_key_pair" "aws_17" {
  key_name   = "aws_17"               # key pair name AWS
  public_key = "${file(var.public_key_path)}"
}

provider "aws" {
  region = "eu-central-1"
}

#resource "aws_vpc" "default" {
#  cidr_block = "10.0.0.0/16"
#}

resource "aws_security_group" "terraform_17" {
  name        = "terraform_17"
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


resource "aws_instance" "ec2_instance_17" {
  ami = "ami-060cde69"
  instance_type = "t2.micro"

  key_name = "${aws_key_pair.aws_17.id}"

  vpc_security_group_ids = ["${aws_security_group.terraform_17.id}"]


  connection {
    # The default username for our AMI
    user = "ubuntu"
    type = "ssh"
    private_key = "${file(var.private_key_path)}"
    # The connection will use the local SSH agent for authentication.
  }

  # install java, create dir
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install openjdk-8-jre-headless",
      "mkdir data",
      "cd data",
      "mkdir inbox",
      "cd ..",
    ]
  }

  # upload jar file
  provisioner "file" {
    source      = "/mnt/c/Java/Sources/sources_aws/aws-io-file/target/io-file-copy-1.0-SNAPSHOT.jar"
    destination = "/home/ubuntu/io-file-copy-1.0-SNAPSHOT.jar"
  }

  # upload inbox directory content
  provisioner "file" {
    source      = "/mnt/c/Java/Sources/sources_aws/aws-io-file/data/inbox/"
    destination = "/home/ubuntu/data/inbox"
  }

  # run jar
  provisioner "remote-exec" {
    inline = [
      "java -jar io-file-copy-1.0-SNAPSHOT.jar",
    ]
  }

}



