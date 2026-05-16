### cloud vars

variable "cloud_id" {
  type        = string
  default     = "cloud_id"
}

variable "folder_id" {
  type        = string
  default     = "folder_id"
}

variable "default_zone_web" {
  type        = string
  default     = "ru-central1-a"
}

variable "default_zone_db" {
  type        = string
  default     = "ru-central1-b"
}

variable "default_cidr_a" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "default_cidr_b" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

### ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "vms_ssh_root_key"
  description = "ssh-keygen -t ed25519"
  sensitive   = true
}

# Переменные для интерполяции

variable "project" {
  type        = string
  default     = "netology"
}

variable "env" {
  type        = string
  default     = "develop"
}

variable "platform" {
  type        = string
  default     = "platform"
}