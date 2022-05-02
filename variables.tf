#--------------------------------------------------------------
# Project Details
#--------------------------------------------------------------
variable "environment" { type = string }

variable "project_name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "region" {
  type = string
}