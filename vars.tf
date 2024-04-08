variable "env" {}
variable "tags" {}
variable "engine" {}
variable "backup_retention_period" {}
variable "preferred_backup_window" {}
variable "skip_final_snapshot" {}
variable "engine_version" {}
variable "subnet_ids" {}
variable "no_of_instances" {}
variable "instance_class" {}

variable "storage_encrypted" {
  default = true
}

variable "allow_subnets" {}
variable "vpc_id" {}