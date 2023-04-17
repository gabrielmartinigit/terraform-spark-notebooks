data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "sm_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com", "glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sm_user_policy" {
  statement {
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "sts:GetCallerIdentity"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sm_user_role"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:*Object"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::sm-bucket-*",
      "arn:aws:s3:::sm-bucket-*/*"
    ]
  }

  statement {
    actions = [
      "sagemaker:CreateApp",
      "sagemaker:DescribeApp"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "elasticmapreduce:*"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}
