# packer {
#   required_plugins {
#     amazon = {
#       version = ">= 1.2.8"
#       source  = "github.com/hashicorp/amazon"
#     }

#   }
# }

# source "amazon-ebs" "ubuntu" {
#   ami_name      = "packer-ubuntu-aws-{{timestamp}}"
#   instance_type = "t2.micro"
#   region        = "us-west-2"
#   source_ami_filter {
#     filters = {
#       name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
#       root-device-type    = "ebs"
#       virtualization-type = "hvm"
#     }
#     most_recent = true
#     owners      = ["099720109477"]
#   }
#   ssh_username = "ubuntu"
#   tags = {
#     "Name"        = "UbuntuWithNginx"
#     "Environment" = "Test"
#     "OS_Version"  = "Ubuntu 22.04"
#     "Release"     = "Latest"
#     "Created-by"  = "Packer"
#   }
# }

# build {
#   name = "aws-nginx-reverse-proxy-server"
#   sources = [
#     "source.amazon-ebs.ubuntu"
#   ]
#   provisioner "shell" {
#     script = "script.sh"
#   }
# }


packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-and-gcp-{{timestamp}}"
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

source "googlecompute" "nginx" {
  project_id              = "third-projecto1"
  source_image            = "ubuntu-2204-jammy-v20241119"
  image_name              = "packer-ubuntu-aws-and-gcp-{{timestamp}}"
  image_family            = "packer-gcp-nginx"
  image_storage_locations = ["us-central1"]
  image_labels = {
    "os" : "ubuntu"
    "application" : "nginx"
  }
  ssh_username  = "ubuntu"
  instance_name = "packer-nginx-image-build"
  zone          = "us-central1-a"
  # network            = "projects/golden-images-svpc/global/networks/golden-images-svpc"
  # subnetwork         = "projects/golden-images-svpc/regions/us-east1/subnetworks/subnet-us-east1"
  # network_project_id = "golden-images-svpc"
  # use_internal_ip    = true
  # omit_external_ip   = true
  # use_iap            = true
  # use_os_login       = true
  # metadata = {
  #   block-project-ssh-keys = "true"
  # }
  tags = ["nginx", "packer"]
}



build {
  name = "aws-nginx-reverse-proxy-server"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.nginx",
  ]
  provisioner "shell" {
    script = "script.sh"
  }
}