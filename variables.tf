variable "eks_cluster_name_primary" {
  description = "Name of the primary EKS Cluster"
  type        = string
  default     = "wp-odr-primary"
}
variable "eks_cluster_name_secondary" {
  type        = string
  description = "Name of the secondary EKS Cluster"
  default     = "wp-odr-secondary"
}

# Default tags to pass to AWS. You can set them here, or in a tfvars file.
variable "default_tags" {
  type = map(string)
  default = {
    github = "hashicorp/learn-waypoint-odr"
  }
}

variable "eks_cluster_primary_ips" {
  description = "The CIDR groups for the Primary Cluster's IP addresses"
  default = {
    vpc      = "10.100.0.0/16"
    private  = "10.100.1.0/24"
    public   = "10.100.2.0/24"
    internet = "0.0.0.0/0"
  }
}

variable "eks_cluster_secondary_ips" {
  description = "The CIDR groups for the Secondary Cluster's IP addresses"
  default = {
    vpc      = "172.30.0.0/16"
    private  = "172.30.1.0/24"
    public   = "172.30.2.0/24"
    internet = "0.0.0.0/0"
  }
}

variable "aws_region" {
  default = "us-east-2"
  type    = string
}

variable "availability_zones" {
  description = "The AZs in which the Clusters will deploy"
  default = {
    zone_one = "us-east-2a"
    zone_two = "us-east-2b"
  }
}
