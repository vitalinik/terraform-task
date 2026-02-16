region        = "ca-central-1"
instance_type = t3.small

allow_ports = ["80", "22", "8080"]

common_tags = {
  Owner       = "Nik"
  Project     = "Free"
  CostCenter  = "567"
  Environment = "prod"
}
