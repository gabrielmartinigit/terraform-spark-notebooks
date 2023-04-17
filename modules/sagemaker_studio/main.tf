### DOMAIN SETTINGS ###
resource "aws_sagemaker_studio_lifecycle_config" "clone_sample" {
  studio_lifecycle_config_name     = "clone-sample"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = base64encode("git clone ${var.sample_repository}")
}

resource "aws_sagemaker_domain" "sm_domain" {
  domain_name = var.domain_name
  #auth_mode   = "IAM"
  auth_mode  = "SSO"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  default_user_settings {
    execution_role = aws_iam_role.sm_domain_role.arn

    jupyter_server_app_settings {
      lifecycle_config_arns = [aws_sagemaker_studio_lifecycle_config.clone_sample.arn]

      code_repository {
        repository_url = var.sample_repository
      }
    }
  }
}

resource "aws_iam_role" "sm_domain_role" {
  name               = "sm_domain_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sm_policy.json
}

resource "random_id" "sm_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "sm_bucket" {
  bucket = "sm-bucket-${random_id.sm_bucket_id.dec}"
}


### USER SETTINGS ###
resource "aws_sagemaker_user_profile" "domain_user" {
  domain_id                      = aws_sagemaker_domain.sm_domain.id
  count                          = length(var.user_names)
  user_profile_name              = var.user_names[count.index]
  single_sign_on_user_identifier = "UserName"
  single_sign_on_user_value      = var.user_names[count.index]
  user_settings {
    execution_role = aws_iam_role.sm_user_role.arn
  }
}

resource "aws_iam_policy" "sm_user_policy" {
  name   = "sm_user_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sm_user_policy.json
}

resource "aws_iam_role" "sm_user_role" {
  name               = "sm_user_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sm_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AwsGlueSessionUserRestrictedServiceRole",
    aws_iam_policy.sm_user_policy.arn
  ]
}

resource "aws_sagemaker_app" "jupyter" {
  domain_id         = aws_sagemaker_domain.sm_domain.id
  count             = length(var.user_names)
  user_profile_name = aws_sagemaker_user_profile.domain_user[count.index].user_profile_name
  app_name          = "default"
  app_type          = "JupyterServer"
  resource_spec {
    lifecycle_config_arn = aws_sagemaker_studio_lifecycle_config.clone_sample.arn
  }
}
