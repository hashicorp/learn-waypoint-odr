# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

module "primary_kubernetes" {
  source                       = "./k8s"
  eks_cluster_name             = var.eks_cluster_name_primary
  eks_vpc_cidr_block           = var.eks_cluster_primary_ips
  eks_vpc_cidr_block_primary   = var.eks_cluster_primary_ips
  eks_vpc_cidr_block_secondary = var.eks_cluster_secondary_ips
  eks_primary_cluster          = var.eks_cluster_name_primary
  availability_zones           = var.availability_zones

}

module "secondary_kubernetes" {
  source                       = "./k8s"
  eks_cluster_name             = var.eks_cluster_name_secondary
  eks_vpc_cidr_block           = var.eks_cluster_secondary_ips
  eks_vpc_cidr_block_primary   = var.eks_cluster_primary_ips
  eks_vpc_cidr_block_secondary = var.eks_cluster_secondary_ips
  eks_primary_cluster          = var.eks_cluster_name_secondary
  availability_zones           = var.availability_zones
}

module "create_peering_secondary_to_primary" {
  source           = "./peering"
  vpc_id_accepter  = module.primary_kubernetes.vpc_id
  vpc_id_requester = module.secondary_kubernetes.vpc_id
}

# Sets up routing for VPC Peering. Runs after VPCs have been created.
# Creates the route for the peering connection from secondary's perspective
module "post_vpc_creation_routing_rules_secondary_to_primary" {
  source                    = "./post_routing"
  vpc_peering_connection_id = module.create_peering_secondary_to_primary.vpc_peering_connection_id
  routing_table_id          = module.secondary_kubernetes.route_table_id
  vpc_id                    = module.secondary_kubernetes.vpc_id
  cidr_block_transit        = var.eks_cluster_primary_ips.vpc
  main_route_table          = module.secondary_kubernetes.main_route_table_id
  private_route_table       = module.secondary_kubernetes.route_table_id
}

# Sets up routing for VPC Peering. Runs after VPCs have been created.
# Creates the route for the peering connection from secondary's perspective
module "post_vpc_creation_routing_rules_primary_to_secondary" {
  source                    = "./post_routing"
  vpc_peering_connection_id = module.create_peering_secondary_to_primary.vpc_peering_connection_id
  routing_table_id          = module.primary_kubernetes.route_table_id
  vpc_id                    = module.primary_kubernetes.vpc_id
  cidr_block_transit        = var.eks_cluster_secondary_ips.vpc
  main_route_table          = module.primary_kubernetes.main_route_table_id
  private_route_table       = module.primary_kubernetes.route_table_id
}


module "cleanup_infra_primary" {
    source = "github.com/webdog/terraform-kubernetes-delete-eni"
    vpc_id = module.primary_kubernetes.vpc_id
    region = var.aws_region
}


module "cleanup_infra_secondary" {
    source = "github.com/webdog/terraform-kubernetes-delete-eni"
    vpc_id = module.secondary_kubernetes.vpc_id
    region = var.aws_region
}