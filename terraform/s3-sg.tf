module "s3_sg" {
  source    = "./modules/s3"
  providers = { aws = aws.sg }

  count = var.enable_dr ? 1 : 0

  bucket_name = var.s3_sg.bucket_name
  kms_key_arn = module.kms_sg.key_arns["s3"]
  tags        = local.common_tags
}
