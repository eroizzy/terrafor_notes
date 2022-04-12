resource "aws_instance" "instance_1" {
  ami               = var.ami # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_type     = var.instance_type
  availability_zone = "us-east-1a"
  security_groups   = [aws_security_group.instances.name]
  user_data         = <<-EOF
    #!/bin/bash
    echo "hello world 1" > index.html
    python3 -m http.server 8080 &
    EOF
  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }

}

resource "aws_instance" "instance_2" {
  ami               = var.ami # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_type     = var.instance_type
  availability_zone = "us-east-1b"
  security_groups   = [aws_security_group.instances.name]
  user_data         = <<-EOF
    #!/bin/bash
    echo "hello world 2" > index.html
    python3 -m http.server 8080 &
    EOF
  tags = {
    Name     = var.instance_name
    ExtraTag = local.extra_tag
  }

}

