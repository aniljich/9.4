#variable "yc_key" {
#  description = "Yandex Cloud key file"
#  type        = string
#}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2

  validation {
    condition     = var.web_server_count >= 2 && var.web_server_count <= 253
    error_message = "web_server_count must be greater 2 and less than 253 because of /24 network."
  }
}
