#Creating ASG to attach to the ALB

resource "aws_autoscaling_group" "webserver-asg" {
  launch_configuration = aws_launch_configuration.webservers.id
  #subnets =  ["${ aws_subnet.private_subnet.id }", "${ aws_subnet.public_subnet.id }","${ aws_subnet.private_subnet2.id }"]
  vpc_zone_identifier = [aws_subnet.private_subnet[0].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[2].id]
  min_size = 2
  max_size = 3

  #load_balancers    = [aws_lb.methods-elb.id]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "Webservers ASG"
    Department          = "Cloud"
    Env                 = "Sandbox"
    Application         = "Sample"
    propagate_at_launch = true
  }
}

#Creating the launch configuration to attach to the ASG

resource "aws_launch_configuration" "webservers" {
  # Amazon linux 2, SSD Volume Type in eu-west-1
  image_id        = lookup(var.aws_amis, var.aws_region)
  #ami = lookup(var.aws_amis, var.aws_region)

  instance_type   = var.instance_type
  security_groups = [aws_security_group.ec2-security-group.id]

  user_data     = file("user_data.sh")

  # Whenever using a launch configuration with an auto scaling group, you must set create_before_destroy = true.
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  lifecycle {
    create_before_destroy = true
  }
}

#creating an ALB to route the traffic to. The ASg will be connected to this ALb

resource "aws_lb" "methods-elb" {
  name = "methods-elb"
  internal = false
  load_balancer_type = "application"
  subnets =  [aws_subnet.public_subnet[2].id, aws_subnet.public_subnet[1].id, aws_subnet.public_subnet[0].id]
  security_groups = ["${aws_security_group.elb-security-group.id}"]

}

resource "aws_lb_listener" "methods-listener" {
  load_balancer_arn = aws_lb.methods-elb.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.methods-tg.arn
  }
}

resource "aws_lb_target_group" "methods-tg" {
  name     = "methods-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_methods.id
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webserver-asg.id
  alb_target_group_arn   = aws_lb_target_group.methods-tg.arn
}