# create a jenkins server ec2 with user data
resource "aws_instance" "jenkins" {
  ami                    = "ami-0d682f26195e9ec0f"
  key_name               = "jenkins-key"
  instance_type          = "t2.micro"
  user_data              = file("install_jenkins.sh") # user data not getting installed !! try file("./install_jenkins.sh")
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  tags = {
    Name = "jenkins-server"
  }
}

data "aws_vpc" "default" {
  id = var.vpc_id
}

# create a secutity group for jenkins server
resource "aws_security_group" "jenkins-sg" {
  name   = "jenkins-sg20"
  vpc_id = "vpc-0f9e917fe3e0553e6"

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Allow port ssh 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow port https 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Allow port http 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#Create S3 bucket for Jenksin Artifacts
resource "aws_s3_bucket" "my-s3-bucket" {
  bucket = "jenkins-s3-bucket-mum-week20terraform"

  tags = {
    Name = "Jenkins-Server"
  }
}

#make sure is prive and not open to public and create Access control List
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket     = aws_s3_bucket.my-s3-bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.my-s3-bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}