output "public_ip" {
	value = "${aws_elb.harold.dns_name}"
}