# Notes

## <u>Setup</u>

-   Install aws cli
-   Install terraform

## <u>Basic Template</u>

[Terraform Documentation - AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

File named main.tf

```
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami             = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
    instance_type   = "t2.micro"
}
```

## <u>Remote Backend</u>

[Terraform Documentation - Remote Backend](https://www.terraform.io/language/state/remote-state-data)

To setup Terraform with remote backend, you will need to create a s3 bucket and a dynamodb. After creating these resources, either manually or via terraform, you can enabled the remote backend in the terraform block.

```
backend "s3" {
    bucket         = "{NAME OF BUCKET}"
    key            = "{PATH/TO/TFSTATE/FILE}"
    region         = "us-east-1"
    dynamodb_table = "{NAME OF DYNAMODB TABLE}"
    encrypt        = true
  }
```

<details>
	<summary>
		<b>Example of backend resource creation:</b>
	</summary>

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-directive-tf-state-eroizzy"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

</details>

<br>

<details>
	<summary>
		<b>Example of backend resource usage:</b>
	</summary>

```
terraform {
  backend "s3" {
    bucket         = "devops-directive-tf-state-eroizzy"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-directive-tf-state-eroizzy"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


```

</details>

## <u>Resource Block</u>

[Terraform Documentation - Resource](https://www.terraform.io/language/resources/syntax)

Resource blocks are used to create a service in aws.

Example template:

```
resource "AWS_SERVICE" "NAME" {
  ## properties of AWS_SERVICE
}
```

Practical Examples from Webapp folder source code:

<details>
	<summary>
		<b>Example of instance:</b>
	</summary>

```
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
```

</details>

<details>
	<summary>
		<b>Example of bucket:</b>
	</summary>

```
resource "aws_s3_bucket" "bucket" {
  bucket        = "eroizzy-webapp-data"
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssec" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "s3_bv" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
```
</details>
<details>
	<summary>
		<b>Example of RDB:</b>
	</summary>

  ```
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
  ```
</details>


## <u>Data Block</u>

[Terraform Documentation - Data](https://www.terraform.io/language/data-sources)

Data blocks are used to access a pre-existing service in aws.

Example template:

```
data "AWS_SERVICE" "NAME" {
  ## properties of AWS_SERVICE
}
```

Practical Examples from Webapp folder source code:

<details>
	<summary>
		<b>Example of Route53 zone:</b>
	</summary>

  ```
  data "aws_route53_zone" "primary" {
    name = "vinajeras.com"
  }
  ```
</details>

<details>
	<summary>
		<b>Example of VPC and Subnets:</b>
	</summary>

  ```
  data "aws_vpc" "default_vpc" {
    default = true
  }

  data "aws_subnets" "default_subnet" {
    filter {
      name   = "vpc-id"
      values = [data.aws_vpc.default_vpc.id]
    }
  }
  ```
</details>

## <u>Variables</U>

[Terraform Documentation - Variables](https://www.terraform.io/language/values/variables)

Variables can be created anywhere in the .tf file. Some of their common properties are 'description', 'type' and 'default'. 

Valid primitive types are:
* string
* number
* bool

More complex variable types are listen in [documentation](https://www.terraform.io/language/values/variables)

variable template:

```
variable "VARIABLE_NAME" {
  description = "Desc of variable"
  type        = DATA_TYPE #data type stored
  default     = "DEFAULT_VALUE"
}
```

They can also be declared locally with the 'locals' block

```
locals {
  VARIABLE_NAME = "VARIABLE_VALUE"
  VARIABLE_NAME2 = "VARIABLE_VALUE2"
}
```

Outputs are bits of information you can output at the end of a plan or apply command. The following command would get the ip address of a RDS database that was created:

```
output "db_instance_addr" {
  value = aws_db_instance.db_instance.address
}
```

### Using Variables ###

To use the variables, we need to give them values. There are multiple ways of giving a variable a value. One way is manually during plan and apply. Any variable without a default value will ask for its value during the plan/apply command is ran. Another way to give it a value is just using the default value listed before.

You can use enviroment variables to give your terraform variable a value. Just prefix the enviroment variable with TF_VAR_\<name\>. 

You can also provide a file or the variables through the CLI commands.
Example:
```
terraform apply -var="db_user=foo" -var="db_pass=foobarboofar" -var-file="path/to/file"
```

Terraform also automatically looks for a terraform.tfvars file in root. You can list values for variables in here:

<details>
	<summary>
		<b>Example of terraform.tfvars:</b>
	</summary>

  ```
  ami           = "ami-04505e74c0741db8d" # Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on 2021-11-29
  instance_name = "hello-world"
  instance_type = "t2.micro"
  region        = "us-east-1"

  domain    = "vinajeras.com"
  subdomain = "terraform.vinajeras.com"

  db_name = "mydb"
  db_user = "foo"
  ```
</details>

### Referring Variables

```
> for variables
var.VAR_NAME

> for local
local.VAR_NAME
```

## <u>Commands</u>

[Terraform Documentation - CLI](https://www.terraform.io/cli)

#### AWS Configure

```
aws configure
```

This sets up ur local credentials with aws. It will asking you for some informtaion:

##### output

```
pwsh> aws configure

AWS Access Key ID [None]: AKIA********
AWS Secret Access Key [None]: Pdr********
Default region name [None]: us-east-1
Default output format [None]: json
```

---

#### Terraform Initilization

```
terraform init
```

Initializes the enviroment to use terraform.

It downloads the required providers and puts them into our working directory in the .terraform folder. Also creates the .terraform.lock.hcl file.

As well as the providers, it will download and install any modules used.

##### Remote Backend

You will need to run terraform init again after adding the remote backend block to the terraform block. To switch back from backend to local, you must remove the backend block from the terraform block and rerun init with a -migrate-state flag.

```
terraform init -migrate-state
```

##### output

<details>
	<summary>
		click to view output
	</summary>

    ```
    pwsh> terraform init

    Initializing the backend...

    Initializing provider plugins...
    - Finding hashicorp/aws versions matching "~> 3.0"...
    - Installing hashicorp/aws v3.75.1...
    - Installed hashicorp/aws v3.75.1 (signed by HashiCorp)

    Terraform has created a lock file .terraform.lock.hcl to record the provider
    selections it made above. Include this file in your version control repository
    so that Terraform can guarantee to make the same selections by default when
    you run "terraform init" in the future.

    Terraform has been successfully initialized!

    You may now begin working with Terraform. Try running "terraform plan" to see
    any changes that are required for your infrastructure. All Terraform commands
    should now work.

    If you ever set or change modules or backend configuration for Terraform,
    rerun this command to reinitialize your working directory. If you forget, other
    commands will detect it and remind you to do so if necessary.
    ```

</details>

---

#### Terraform Plan

```
terraform plan
```

shows you a preview of what will change on your aws

##### output

<details>
  <summary>click to view output</summary>

```
pwsh> terraform plan

Terraform used the selected providers to generate the following
execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                                  = "ami-04505e74c0741db8d"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags_all                             = (known after apply)
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't
guarantee to take exactly these actions if you run "terraform apply" now.
```

</details>

---

#### Terraform Apply

```
terraform apply
```

##### output

<details>
  <summary>click to view output</summary>

```
pwsh> terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.example will be created
  + resource "aws_instance" "example" {
      + ami                                  = "ami-04505e74c0741db8d"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags_all                             = (known after apply)
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.example: Creating...
aws_instance.example: Still creating... [10s elapsed]
aws_instance.example: Still creating... [20s elapsed]
aws_instance.example: Still creating... [30s elapsed]
aws_instance.example: Still creating... [40s elapsed]
aws_instance.example: Creation complete after 45s [id=i-0db86d6f0bbee9806]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

</details>

---

#### Terraform Destroy

```
terraform destroy
```

##### Output

<details>
  <summary>click to view output</summary>

```
pwsh> terraform destroy
aws_instance.example: Refreshing state... [id=i-0db86d6f0bbee9806]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.example will be destroyed
  - resource "aws_instance" "example" {
      - ami                                  = "ami-04505e74c0741db8d" -> null
      - arn                                  = "arn:aws:ec2:us-east-1:170114412025:instance/i-0db86d6f0bbee9806" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "us-east-1a" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0db86d6f0bbee9806" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - monitoring                           = false -> null
      - primary_network_interface_id         = "eni-0635a4463a64b9152" -> null
      - private_dns                          = "ip-172-31-95-77.ec2.internal" -> null
      - private_ip                           = "172.31.95.77" -> null
      - public_dns                           = "ec2-3-93-79-194.compute-1.amazonaws.com" -> null
      - public_ip                            = "3.93.79.194" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "default",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-026cd6dca782182a1" -> null
      - tags                                 = {} -> null
      - tags_all                             = {} -> null
      - tenancy                              = "default" -> null
      - vpc_security_group_ids               = [
          - "sg-0bedd91321189b1a6",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
          - instance_metadata_tags      = "disabled" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-05c8ffac839f8fdc8" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.example: Destroying... [id=i-0db86d6f0bbee9806]
aws_instance.example: Still destroying... [id=i-0db86d6f0bbee9806, 10s elapsed]
aws_instance.example: Still destroying... [id=i-0db86d6f0bbee9806, 20s elapsed]
aws_instance.example: Still destroying... [id=i-0db86d6f0bbee9806, 30s elapsed]
aws_instance.example: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

</details>

---
