variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
}

variable "instance_name" {
  description = "Name of ec2 instance"
  type        = string
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_name" {
  description = "DB name"
  type        = string
}

variable "db_user" {
  description = "DB username"
  type        = string
  default     = "foo"
}

variable "db_pass" {
  description = "DB password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Default Region Provider"
  type        = string
  default     = "us-east-1"
}

variable "domain" {
  description = "Domain of website"
  type        = string
}

variable "subdomain" {
  description = "Subdomain of website"
  type        = string
}