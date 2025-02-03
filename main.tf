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

resource "aws_key_pair" "id_rsa" {
  key_name = "ssh_key"
  public_key = var.public_key
}

resource "aws_security_group" "web_sg" {
  name = "web_sg"
  description = "Security group for web servers"
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource aws_vpc_security_group_ingress_rule "web_sg_ssh" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4       = ["0.0.0.0/0"]
}

resource aws_vpc_security_group_ingress_rule "web_sg_http" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4       = ["0.0.0.0/0"]
}

resource "aws_instance" "web" {
  security_groups = [aws_security_group.web_sg.name]
  key_name        = aws_key_pair.id_rsa.key_name
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  tags            = var.instance_tags

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }

  provisioner "file" {
    source = "files/index.html"
    destination = "/home/ubuntu/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html"
    ]
  }

  connection {
    host = self.public_ip
    user = "ubuntu"
    port = 22
    type = "ssh"
    private_key = var.connection_private_key
  }
  
}

