data "aws_vpc" "main" {
  # id = "vpc-034016e94e8f4309c"
  id = var.vpc_id
}

resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
			prefix_list_ids  = []
			security_groups = []
			self = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.my_ip_with_cidr]
      ipv6_cidr_blocks = []
			prefix_list_ids  = []
			security_groups = []
			self = false
    }
  ]

  egress = [
    {
			description = "outgoing traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
			prefix_list_ids  = []
			security_groups = []
			self = false
    }
  ]
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMxW+GQgPiyrxfpDKhOQOypWw8DXEIyZEewEQCFiadJNLk8uK9ZHKpTiA+eb7akn2Cu3KEqADHECfknU2Y8p6xJXsiI1fHM2g0m67oO/yUG7TDQmU6ZprNVsugrB6Q/11Wb6HjRQhsGZWJmrBr9LdqfNkLXAELzO96lWx94cBgMIK4C5s//8GipuuDfQictkUuEg0gC/MTTedojn7eihy5OqF6712A+XNl3ZM1tt6L9iZZzQvxg/e6bxAcbQ+Em5fgmSjrMva/LM9ZRS+dhBnvyCSD4QwfC8KpYCKQkFG2eLPyrSJBksthEe+BKP77LJnn39stHrKcf7rJTP0qnLoCtsGMB0d4u0yZbsRSsnJxfyJz2JcShLMGjEhqcz12bDNGsig95BwSvlrVqJDR54f0cNczRTN2UkQOiTTjYVXFy1XLEEKYBCy38/F0bau3qPgGge4XmiiZX9SFCbttuSf4EbqrmnKmWiOVhIR2lVvXdAItNR0qJ0kvAvQ5m74FyaU= nesh@Neshs-MBP.lan"
}

data "template_file" "user_data" {
	template = file("./userdata.yaml")
}

resource "aws_instance" "my_server" {
  ami           = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
	key_name = "${aws_key_pair.deployer.key_name}"
	vpc_security_group_ids = [aws_security_group.sg_my_server.id]
	user_data = data.template_file.user_data.rendered
  provisioner "file" {
    content     = "mars"
    destination = "/home/ec2-user/barsoon.txt"
		connection {
			type     = "ssh"
			user     = "ec2-user"
			host     = "${self.public_ip}"
			private_key = "${file("~/.ssh/terraform")}"
		}
  }

  tags = {
    Name = "MyServer"
  }
}

