## EFS
resource "aws_security_group" "efs_sg" {
  name   = "efs-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_subnet.public1.cidr_block}",
      "${aws_subnet.public2.cidr_block}"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

resource "aws_efs_file_system" "efs" {
  tags = {
    Name = "test-efs"
  }
}

resource "aws_efs_mount_target" "efs_public1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public1.id
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_mount_target" "efs_public2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public2.id
  security_groups = [aws_security_group.efs_sg.id]
}