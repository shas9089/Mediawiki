provider "aws" {
  region = "ap-south-1"
  profile = "shashank"
  access_key = ""
  secret_key = ""
}

data "aws_availability_zones" "data_az" {
  
}

#-------------- Key-Pair --------------#
resource "aws_key_pair" "my_key_pair" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


#-------------- AWS Instances --------------#
resource "aws_instance" "first_web_instance" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.my_key_pair.id}"
  vpc_security_group_ids = ["${var.web_security_group}"]
  subnet_id = "${var.web_subnet_a}"

  tags = {
    Name = "first_web_instance"
    Project = "mediawiki"
  }
}

resource "aws_instance" "second_web_instance" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.my_key_pair.id}"
  vpc_security_group_ids = ["${var.web_security_group}"]
  subnet_id = "${var.web_subnet_b}"

  tags = {
    Name = "second_web_instance"
    Project = "mediawiki"
  }
}

resource "aws_instance" "my_db_instance" {
  ami = "${var.ami}"
  instance_type = "${var.web_instance_type}"
  key_name = "${aws_key_pair.my_key_pair.id}"
  vpc_security_group_ids = ["${var.db_security_group}"]
  subnet_id = "${var.db_subnet}"

  tags = {
    Name = "my_db_instance"
    Project = "mediawiki"
  }
}

#-------------- ELB --------------#
resource "aws_elb" "my_elb" {

  provisioner "local-exec" {
    
    command = <<EOD
cat <<EOF > ../aws_hosts 

[mediawiki-webserver]
mediawiki-webserver-1 ansible_host=${aws_instance.first_web_instance.public_ip}
mediawiki-webserver-2 ansible_host=${aws_instance.second_web_instance.public_ip}

[mediawiki-webserver:vars]
lb_url=${aws_elb.my_elb.dns_name}
database_ip=${aws_instance.my_db_instance.private_ip}

[mediawiki-database]
mediawiki-database-1 ansible_host=${aws_instance.my_db_instance.private_ip}

[mediawiki-database:vars]
firstweb=${aws_instance.first_web_instance.private_ip}
secondweb=${aws_instance.second_web_instance.private_ip}

[mysql-servers:children]
mediawiki-database

[apache-servers:children]
mediawiki-webserver
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.first_web_instance.id} ${aws_instance.second_web_instance.id} ${aws_instance.my_db_instance.id} --profile ${var.aws_profile} && cd .. && ansible-playbook -i aws_hosts mediawiki-install.yaml"
  }
  
  name = "media-wiki-elb"
  subnets = ["${var.web_subnet_a}", "${var.web_subnet_b}"]
  instances = ["${aws_instance.first_web_instance.id}", "${aws_instance.second_web_instance.id}"]
  security_groups = ["${var.web_security_group}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    timeout             = "3"
    target              = "TCP:80"
    interval            = "30"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300

  tags = {
    Name = "my_elb"
    Project = "mediawiki"
  }
}

resource "aws_lb_cookie_stickiness_policy" "mw_lb_policy" {
  name                     = "mw-lb-policy"
  load_balancer            = "${aws_elb.my_elb.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}
