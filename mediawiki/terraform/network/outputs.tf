output "custom_vpc" {
  value = "${aws_vpc.custom_vpc.id}"
}

output "web_security_group" {
  value = "${aws_security_group.public_security_group.id}"
}

output "db_security_group" {
  value = "${aws_security_group.private_security_group.id}"
}

output "web_subnet_a" {
  value = "${aws_subnet.public_subnet_a.id}"
}

output "web_subnet_b" {
  value = "${aws_subnet.public_subnet_b.id}"
}

output "db_subnet" {
  value = "${aws_subnet.private_subnet_a.id}"
}