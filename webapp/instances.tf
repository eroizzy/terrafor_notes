resource "aws_instance" "instance_1" {
  ami               = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"
  security_groups   = [aws_security_group.instances.name]
  user_data         = <<-EOF
    #!/bin/bash
    echo "hello world 1" > index.html
    python3 -m http.server 8080 &
    EOF
}

resource "aws_instance" "instance_2" {
  ami               = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  security_groups   = [aws_security_group.instances.name]
  user_data         = <<-EOF
    #!/bin/bash
    echo "hello world 2" > index.html
    python3 -m http.server 8080 &
    EOF
}