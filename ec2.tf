data "aws_ssm_parameter" "amazonlinux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64" # x86_64
}

resource "aws_instance" "sample" {
  ami                    = data.aws_ssm_parameter.amazonlinux_2023.value
  vpc_security_group_ids = [aws_security_group.ec2.id]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_a.id
  iam_instance_profile   = aws_iam_instance_profile.ssm_role.name
  user_data              = file("userdata.sh")

  tags = {
    Name = "${var.project}-${var.env}-instance"
  }
}

resource "aws_security_group" "ec2" {
  name   = "${var.project}-${var.env}-ec2-sg"
  vpc_id = aws_vpc.example.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "ssm_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ssm_role" {
  name = "EC2RoleforSSM"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name               = "EC2RoleforSSM"
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_role" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
