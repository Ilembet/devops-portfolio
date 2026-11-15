variable "zones" {
  description = "Availability zones; one subnet and one VM per zone"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-d"]
}

variable "name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "web"
}

variable "ssh_public_key_path" {
  description = "Public SSH key that will be allowed to log in as the ubuntu user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "allowed_cidr" {
  description = "Who may reach SSH (22) and the app (8000). Narrow it to your IP/32 when possible"
  type        = string
  default     = "0.0.0.0/0"
}

variable "vm_cores" {
  description = "vCPU count per VM"
  type        = number
  default     = 2
}

variable "vm_memory_gb" {
  description = "RAM per VM, GB"
  type        = number
  default     = 2
}

variable "vm_core_fraction" {
  description = "Guaranteed vCPU share, percent (20 is the cheapest for standard-v3)"
  type        = number
  default     = 20
}

variable "preemptible" {
  description = "Preemptible VMs are much cheaper but can be stopped by the cloud at any time"
  type        = bool
  default     = true
}
