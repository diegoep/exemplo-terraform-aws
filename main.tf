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
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "web_sg" {
  name = "web_sg"
  description = "Security group for web servers"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "web_sg_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
}

resource "aws_instance" "web" {
  security_groups = [aws_security_group.web_sg.name]
  key_name = aws_key_pair.id_rsa.key_name
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = var.instance_tags
  provisioner "local-exec" {
    command = "echo 'Configurando o software da instância recém-criada...' > /tmp/resultado.txt"
  }
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
    private_key = file("~/.ssh/id_rsa")
  }
  
}

