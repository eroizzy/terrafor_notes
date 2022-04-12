resource "aws_db_instance" "db_instance" {
  allocated_storage   = 20
  storage_type        = "standard"
  engine              = "mariadb"
  engine_version      = "10.6.7"
  instance_class      = "db.t3.micro"
  db_name             = "mydb"
  username            = "foo"
  password            = "floobarbaz" # Constraints: At least 8 printable ASCII characters. Can't contain any of the following: / (slash), '(single quote), "(double quote) and @ (at sign).
  skip_final_snapshot = true
}