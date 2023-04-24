resource "aws_emr_cluster" "cluster" {
  name                   = var.cluster_name
  release_label          = var.emr_version
  service_role           = aws_iam_role.cluster_role.arn
  applications           = var.cluster_applications
  termination_protection = false
  auto_termination_policy {
    idle_timeout = 604800
  }
  ec2_attributes {
    subnet_ids                        = var.subnet_ids
    emr_managed_master_security_group = var.security_group_ids
    emr_managed_slave_security_group  = var.security_group_ids
    instance_profile                  = aws_iam_role.instance_role.arn
  }
  master_instance_group {
    name           = "EMR Master"
    instance_type  = var.master_instance_type
    instance_count = var.master_instance_count
  }
  core_instance_group {
    name           = "EMR Core"
    instance_type  = var.core_instance_type
    instance_count = var.core_instance_count
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "emr_cluster_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.emr_cluster_policy.json
}

resource "aws_iam_role" "instance_role" {
  name               = "emr_instance_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.emr_instance_policy.json
}
