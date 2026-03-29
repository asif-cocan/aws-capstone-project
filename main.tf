// Terraform script with EC2 user data, Security group, VPC, Multiple Subnets, Route table, Internet Gateway, ELB..etc  - Till Step 9
//EC2 block and target group attach block deleted
//Adding RDS and private subnets

provider "aws" {
  region = "ap-south-1"
}

resource "aws_launch_template" "lt" {
  name_prefix   = "capstone-lt"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  key_name      = "capstone-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.my_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx

              echo "<h1>Auto Scaling Server $(hostname)</h1>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 3
  min_size         = 1

  vpc_zone_identifier = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]

  target_group_arns = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Capstone-ASG-Instance"
    propagate_at_launch = true
  }
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "capstone-vpc"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name = "capstone-db-subnet"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

resource "aws_db_instance" "db" {
  identifier         = "capstone-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = "admin"
  password           = "Password123!"   # we’ll secure later
  db_subnet_group_name = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible = false
  skip_final_snapshot = true
}


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "capstone-public-subnet"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "capstone-public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "capstone-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "capstone-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_lb_target_group" "tg" {
  name     = "capstone-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb" "alb" {
  name               = "capstone-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets = [
  aws_subnet.public_subnet.id,
  aws_subnet.public_subnet_2.id
]
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.my_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "my_sg" {
  name        = "capstone-sg"
  description = "Allow SSH and HTTP"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
}

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # later we restrict this
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


