data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_name]
  }
  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }

}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = var.instance_tags
}

