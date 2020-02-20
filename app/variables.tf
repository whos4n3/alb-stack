
variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

#Amazon linux 2
variable "aws_amis" {
  default = {
    eu-west-1 = "ami-0713f98de93617bb4"
    us-east-1 = "ami-062f7200baf2fa504"
    us-west-1 = "ami-03caa3f860895f82e"
    us-west-2 = "ami-04590e7389a6e577c"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_count" {
  default = "2"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}