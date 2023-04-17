module "cogna_sagemaker_studio" {
  source      = "./modules/sagemaker_studio"
  domain_name = "cogna-test"
  vpc_id      = "vpc-09ff93353befb8bfe"
  subnet_ids  = ["subnet-06ea3ca72c0b087cf", "subnet-04e32cd504ec1071b"]
  user_names  = ["user-test1", "user-test2"]
}
