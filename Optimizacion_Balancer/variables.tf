variable "aws_region" {
  description = "Region del provider"
  default     = "us-east-1"
  type        = string

  validation {
    condition     = contains(["us-east-1", "us-east-2"], var.aws_region)
    error_message = "La region debe ser us-east-1 o us-east-2"
  }
}

variable "number_servers" {
  default     = 0
  type        = number
  description = "cantidad de servidores"

  validation {
    condition     = var.number_servers >= 0
    error_message = "La cantidad de servidores debe ser mayor a 0"
  }
}

variable "user_specified_ami" {
  default     = null
  description = "Imagen Especifica"
  type        = string
}

variable "amount_subnets" {
  default     = 1
  description = "Cantidad de Subnets"
  type        = number

  validation {
    condition     = var.amount_subnets > 0
    error_message = "La cantidad de servidores debe ser mayor a 0"
  }
}
