
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

#Amazon linux 2
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-0713f98de93617bb4"
    eu-west-2 = "ami-0389b2a3c4948b1a0"
    us-east-1 = "ami-062f7200baf2fa504"
    us-west-1 = "ami-03caa3f860895f82e"
  }
}

variable "instance_type" {
  default = "t3.micro"
}

variable "instance_count" {
  default = "2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "default_tags" { 
    type = map 
    default = { 
        Department: "CDC",
        App: "Sample",
        Env: "Sandbox"
  } 
}

variable "subnet_cidrs_priv" {
  description = "Subnet CIDRs for Private subnets (length must match configured availability_zones)"
  # https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet-iprange-newbits-netnum-
  default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  type = list
}

variable "subnet_cidrs_pub" {
  description = "Subnet CIDRs for Private subnets (length must match configured availability_zones)"
  # https://www.terraform.io/docs/configuration/interpolation.html#cidrsubnet-iprange-newbits-netnum-
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  type = list
}