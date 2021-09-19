data "aws_availability_zones" "data_az" {
  
}

#-------------- VPC --------------#
resource "aws_vpc" "custom_vpc" {
  cidr_block = "192.168.0.0/16"
    
  tags = {
      Name = "mediawiki"
      Project = "mediawiki"
  }
}

#-------------- Internet Gateway --------------#
resource "aws_internet_gateway" "web_igw" {
  vpc_id ="${aws_vpc.custom_vpc.id}"
  
  tags = {
      Name = "mediawiki"
      Project = "mediawiki"
    }
}

#-------------- Route Tables --------------#
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.custom_vpc.id}"
  route{
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.web_igw.id}"
  }

  tags = {
      Name = "mediawiki_rt_public"
      Project = "mediawiki"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${aws_vpc.custom_vpc.id}"

  tags = {
      Name = "mediawiki_rt_private"
      Project = "mediawiki"
  }
}

#-------------- Subnets --------------#
resource "aws_subnet" "public_subnet_a" {
  vpc_id = "${aws_vpc.custom_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[0]}"
  cidr_block = "192.168.0.0/24"
  map_public_ip_on_launch = true
  
  tags = {
      Name = "mediawiki_sub_public_a"
      Project = "mediawiki"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id = "${aws_vpc.custom_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[1]}"
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
      Name = "mediawiki_sub_public_b"
      Project = "mediawiki"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id = "${aws_vpc.custom_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[0]}"
  cidr_block = "192.168.2.0/24"
  
  tags = {
      Name = "mediawiki_sub_private_a"
      Project = "mediawiki"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = "${aws_vpc.custom_vpc.id}"
  availability_zone = "${data.aws_availability_zones.data_az.names[1]}"
  cidr_block = "192.168.3.0/24"
  
  tags = {
      Name = "mediawiki_private_b"
      Project = "mediawiki"
  }
}

#-------------- Route Subnet Association --------------#
resource "aws_route_table_association" "public_rta_a" {
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id = "${aws_subnet.public_subnet_a.id}"
}

resource "aws_route_table_association" "public_rta_b" {
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id = "${aws_subnet.public_subnet_b.id}"
}

resource "aws_route_table_association" "private_rta_a" {
  route_table_id = "${aws_route_table.private_rt.id}"
  subnet_id = "${aws_subnet.private_subnet_a.id}"
}

resource "aws_route_table_association" "private_rta_b" {
  route_table_id = "${aws_route_table.private_rt.id}"
  subnet_id = "${aws_subnet.private_subnet_b.id}"
}

#-------------- Security Groups --------------#

resource "aws_security_group" "public_security_group" {
  name = "web_access"
  description = "default access to instances over port 80 and port 22"
  vpc_id = "${aws_vpc.custom_vpc.id}"

  tags = {
      Name = "mediawiki_sg_public"
      Project = "mediawiki"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #http
  ingress{
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_security_group" {
  name = "database_access"
  description = "default access to instances over port 22 and port 3306"
  vpc_id = "${aws_vpc.custom_vpc.id}"

  tags = {
      Name = "mediawiki_sg_private"
      Project = "mediawiki"
  }

  #ssh
  ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  #mysql
  ingress{
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress{
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}






