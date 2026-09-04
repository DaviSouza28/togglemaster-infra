variable "vpc_id" {
  description = "ID da VPC onde os servicos serao executados"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC utilizado para restringir o acesso aos bancos"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "auth_db_password" {
  description = "Senha do banco Auth"
  type        = string
  sensitive   = true
}

variable "flag_db_password" {
  description = "Senha do banco Flag"
  type        = string
  sensitive   = true
}

variable "targeting_db_password" {
  description = "Senha do banco Targeting"
  type        = string
  sensitive   = true
}
