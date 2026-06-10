terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Workspace API-driven no Terraform Enterprise:
  # o AAP envia esta configuração via hashicorp.terraform.configuration_version
  # e dispara o run via hashicorp.terraform.run — não é necessário bloco cloud/backend.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "better-together-demo"
      ManagedBy   = "terraform"
      Provisioner = "aap-workflow"
    }
  }
}

# ---------------------------------------------------------------------------
# Rede
# ---------------------------------------------------------------------------

resource "aws_vpc" "demo" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.prefix}-vpc" }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
  tags   = { Name = "${var.prefix}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = { Name = "${var.prefix}-public" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }

  tags = { Name = "${var.prefix}-rt-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Security Group
# ---------------------------------------------------------------------------

resource "aws_security_group" "web" {
  name_prefix = "${var.prefix}-web-"
  description = "HTTP + SSH para a demo Better Together"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (Ansible)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.prefix}-sg-web" }
}

# ---------------------------------------------------------------------------
# Instâncias EC2 (web servers)
# ---------------------------------------------------------------------------

data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat

  filter {
    name   = "name"
    values = ["RHEL-9.*_HVM-*-x86_64-*-Hourly2-GP3"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "demo" {
  key_name   = "${var.prefix}-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "web" {
  count = var.web_instance_count

  ami                    = data.aws_ami.rhel9.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.demo.key_name

  tags = {
    Name = "${var.prefix}-web-${count.index + 1}"
    Role = "webserver"          # usado pelo inventário dinâmico (keyed_groups)
    App  = "better-together"
  }
}
