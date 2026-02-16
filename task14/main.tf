provider "aws" {
  region = "ca-central-1"
}

data "aws_regions" "current" {}
data "aws_availability_zones" "availabile" {}

locals {
  full_project_name = "${var.project_name}-${var.environment}"
  project_owner     = "${var.owner} owner of ${var.project_name}"
}

locals {
  country  = "Canada"
  city     = "Toronto"
  az_list  = join(", ", data.aws_availability_zones.availabile.names)
  region   = data.aws_regions.current.descкription
  location = "In ${local.region} there are AZ: ${local.az_list}"
}

resource "aws_eip" "my_static_ip" {
  tags = {
    Name       = "Static-IP"
    Owner      = var.owner
    Project    = local.full_project_name
    proj_owner = local.project_owner
    city       = local.city
    region_azs = local.az_list
    Location   = local.location
  }

}
