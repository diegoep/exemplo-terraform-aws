variable "ami_name" {
  description = "value of the AMI"
  default = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}
variable "ami_virtualization_type" {
    description = "value of the AMI virtualization type"
    default = "hvm"
}

variable "instance_type" {
    description = "value of the instance type"
    default = "t2.micro"
}

variable "instance_tags" {
    description = "value of the instance tags"
    default = {
        Name = "HelloWorld"
        Group = "Virtualização"
    }
}

variable "connection_private_key" {
  description = "private key to copy files"
}