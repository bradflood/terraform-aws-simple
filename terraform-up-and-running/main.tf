terraform {
  required_version = "< 0.12"
    backend "s3" {
        bucket = "bwflood-terraform-state-dev"
        key = "global/s3/terraform.tfstate"
        region = "us-east-1"
        encrypt = true
        profile = "default"
    }
}

provider "aws" { 
	version = "~>1.57"
	region = "us-east-1" 
}

data "aws_availability_zones" "all" {}
data "template_file" "user_data" {
  template = "${file("user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
  }
}

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default = 8080
}

resource "aws_launch_configuration" "henry" {
	image_id = "ami-40d28157"
	instance_type = "t2.micro"
	security_groups = ["${aws_security_group.bubcus_sg.id}"]
	user_data       = "${data.template_file.user_data.rendered}"
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_autoscaling_group" "jebediah" {
	launch_configuration = "${aws_launch_configuration.henry.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	load_balancers = ["${aws_elb.harold.name}"]
	health_check_type = "ELB"
	min_size = 2
	max_size = 10
	
	tag {
		key = "Name"
		value = "terraform-asg-example"
		propagate_at_launch = true
	}
	
}

resource "aws_security_group" "bubcus_sg" {
	name = "terraform-bubcus-instance"
	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0" ] 
	}
	lifecycle {
		create_before_destroy = true
	}	
}

resource "aws_elb" "harold" {
	name = "terraform-asg-example"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	security_groups= ["${aws_security_group.harold_elb_sg.id}"] 
	
	listener {
		lb_port = 80
		lb_protocol = "http"
		instance_port = "${var.server_port}"
		instance_protocol = "http"
	}
	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 3
		timeout = 3
		interval = 30
		target = "HTTP:${var.server_port}/"
	}
}
resource "aws_security_group" "harold_elb_sg" {
	name = "terraform-elb"
	ingress {
		from_port = "80"
		to_port = "80"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0" ] 
	}
	egress {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0" ] 
	}	
	lifecycle {
		create_before_destroy = true
	}	
}
