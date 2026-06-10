variable "prefix" {
  description = "Prefixo de nomenclatura dos recursos"
  type        = string
  default     = "bt-demo"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da subnet pública"
  type        = string
  default     = "10.42.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "CIDR autorizado a acessar SSH (restrinja ao IP do AAP/EE)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "Chave pública SSH usada pelo Ansible (par da credencial Machine no AAP)"
  type        = string
}

variable "web_instance_count" {
  description = "Quantidade de web servers"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}
