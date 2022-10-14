output "region" {
  value = var.aws_region
}

output "primary_cluster_name" {
  value = var.eks_cluster_name_primary
}

output "secondary_cluster_name" {
  value = var.eks_cluster_name_secondary
}