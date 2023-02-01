# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "eks_arn" {
  value = aws_iam_role.eks.arn
}

output "eks_role_name" {
  value = aws_iam_role.eks.name
}