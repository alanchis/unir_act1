packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "UbuntuWithNginx"
    "Environment" = "Test"
    "OS_Version"  = "Ubuntu 22.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

build {
  name = "aws-nginx-reverse-proxy-server"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  #   provisioner "shell" {
  #     inline = [
  #       "echo Installing Updates",
  #       "sudo apt-get update",
  #       "sudo apt-get upgrade -y",
  #       "sudo apt-get install -y nginx"
  #     ]
  #   }
  provisioner "shell" {
    script = "script.sh"
  }
}