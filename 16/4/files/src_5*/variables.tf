variable "cloud_id" {
  type        = string
  sensitive   = true
}

variable "folder_id" {
  type        = string
  sensitive   = true
}

variable "public_key" {
  type    = string
  sensitive = true
}

variable "service_account_key_file" {
  type    = string
  sensitive = true
}

variable "env_name" {
  type        = string
  default     = "develop"
}

variable "mysql_environment" {
  type        = string
  default     = "PRESTABLE"
}

variable "mysql_cluster_name" {
  description = "Имя кластера MySQL"
  type        = string
  default     = "example"
}

variable "mysql_ha" {
  description = "Включить высокую доступность (2 хоста)"
  type        = bool
  default     = true
}

variable "mysql_db_name" {
  description = "Имя базы данных"
  type        = string
  default     = "test"
}

variable "mysql_user_name" {
  description = "Имя пользователя MySQL"
  type        = string
  default     = "app"
}

variable "mysql_user_password" {
  description = "Пароль пользователя MySQL"
  type        = string
  sensitive   = true
  default     = ""
}