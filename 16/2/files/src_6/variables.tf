### cloud vars

variable "cloud_id" {
  type        = string
  default     = "cloud_id"
}

variable "folder_id" {
  type        = string
  default     = "folder_id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
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