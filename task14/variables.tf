variable "region" {
  description = "Please Enter AWS Region to deploy Server"
  type        = string
  default     = "ca-central-1"
}

variable "owner" {
  default     = "Vitalii"
}

variable "project_name" {
  default     = "MyProject"
}

variable "environment" {
  default     = "DEV"
}








variable "instance_type" {
  description = "Please Enter AWS Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "allow_ports" {
  description = "List of Ports to open for Server"
  type        = list(any) #list(number)
  default     = ["80", "443", "22", "8080"]
}

variable "enable_detailed_monitoring" {
  description = "Enable Detailed Monitoring for EC2 Instance"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(any) #map(string)
  default = {
    Owner       = "Vitalii"
    Project     = "Phoenix"
    CostCenter  = "1234567"
    Environment = "development"
  }
}
