provider "aws" { 
	region = "us-east-2" 
}

resource "aws_instance" "bubcus" {
	ami = "ami-04328208f4f0cf1fe"
	instance_type = "t2.micro"
	tags = {
    	Name = "bubcus"
    	Terraform = "true"
    	Environment = "dev"
    	Contact = "Brad Flood"
  	}
}

