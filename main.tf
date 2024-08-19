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
  public_key = <<EOF
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDK/txQ5QMjuWIy08+jSQ6iz9tOJ7Lwt5UNqQpNbojUeRKlWQE95suov0Whs1CVag3M+t9yBtwivLCErRCWIALTaHKIsDdlO/aJQ0lL5sG2vaVvN1ndwGVX44OrjShiarWSvA219qA3Vl36ZfsmETYOtGaih+PKNMN2cNrlkk/6CyIk6tnO4tJX5MFM0UJ4lbWDM/Mvi+HVHiflZer626lz2RyzU0bzuXq9pwdBHadLeMdYJBusJcVTTx/RPimM0HCEL8tydh/RT2Cnrv0u27pm88S738vz1bTN+tgLjYgUrtVJLKIS8RYklTiRwhmXply8S7qNPl1sf1prdtJBuClGmUlqDlPubjOXC1sSpiREzEtuWIqUxU3CmX5jvCMSx2PzjtlYlZMZjo57mfW0sZ5ZathiF6HYuf9k64q8HapHrfjbZmhfdWABwu5o4ryo67//pA1vDuBjkJS4ECmrTN4gbtbwGr61I0nl74wFgCpeuRl9ms+ZGdP8GmXgkav5/6U= diegopessoa@Diegos-MacBook-Pro.local
    EOF
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
    command = "mkdir files"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }

  provisioner "local-exec" {
    command = "${format("cat <<\"EOF\" > \"%s\"\n%s\nEOF", "files/index.html", "files/index.html")}"
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

