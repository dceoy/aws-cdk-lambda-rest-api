locals {
  image_name          = "web"
  lambda_architecture = "arm64"
  docker_image_build_platforms = {
    "x86_64" = "linux/amd64"
    "arm64"  = "linux/arm64"
  }
  repo_root = get_repo_root()
  env_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=16"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.env_vars.locals.terraform_s3_bucket
    key            = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.env_vars.locals.region
    encrypt        = true
    dynamodb_table = local.env_vars.locals.terraform_dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_vars.locals.region}"
  default_tags {
    tags = {
      SystemName = "${local.env_vars.locals.system_name}"
      EnvType    = "${local.env_vars.locals.env_type}"
    }
  }
}
EOF
}

catalog {
  urls = [
    "github.com/dceoy/terraform-aws-docker-based-lambda",
    "${local.repo_root}/modules/ecr",
    "${local.repo_root}/modules/docker",
    "${local.repo_root}/modules/lambda",
    "${local.repo_root}/modules/dynamodb"
  ]
}

inputs = {
  system_name                     = local.env_vars.locals.system_name
  env_type                        = local.env_vars.locals.env_type
  create_kms_key                  = true
  kms_key_deletion_window_in_days = 30
  kms_key_rotation_period_in_days = 365
  ecr_repository_names = {
    connect-handler     = "${local.env_vars.locals.system_name}-${local.env_vars.locals.env_type}-connect-handler"
    disconnect-handler  = "${local.env_vars.locals.system_name}-${local.env_vars.locals.env_type}-disconnect-handler"
    sendmessage-handler = "${local.env_vars.locals.system_name}-${local.env_vars.locals.env_type}-sendmessage-handler"
    default-handler     = "${local.env_vars.locals.system_name}-${local.env_vars.locals.env_type}-default-handler"
  }
  ecr_image_secondary_tags                 = compact(split(",", get_env("DOCKER_METADATA_OUTPUT_TAGS", "latest")))
  ecr_image_tag_mutability                 = "MUTABLE"
  ecr_force_delete                         = true
  ecr_lifecycle_policy_semver_image_count  = 9999
  ecr_lifecycle_policy_any_image_count     = 10
  ecr_lifecycle_policy_untagged_image_days = 7
  docker_image_force_remove                = true
  docker_image_build                       = local.env_vars.locals.docker_image_build
  docker_image_build_targets = {
    connect-handler     = "connect_handler"
    disconnect-handler  = "disconnect_handler"
    sendmessage-handler = "sendmessage_handler"
    default-handler     = "default_handler"
  }
  docker_image_build_context                  = "${local.repo_root}/docker"
  docker_image_build_dockerfile               = "Dockerfile"
  docker_image_build_build_args               = {}
  docker_image_build_platform                 = local.docker_image_build_platforms[local.lambda_architecture]
  docker_image_primary_tag                    = get_env("DOCKER_PRIMARY_TAG", run_cmd("--terragrunt-quiet", "git", "rev-parse", "--short", "HEAD"))
  docker_host                                 = get_env("DOCKER_HOST", "unix:///var/run/docker.sock")
  dynamodb_hash_key_for_connection_table      = "connectionId"
  dynamodb_billing_mode                       = "PAY_PER_REQUEST"
  dynamodb_point_in_time_recovery_enabled     = false
  dynamodb_table_class                        = "STANDARD"
  lambda_architectures                        = [local.lambda_architecture]
  lambda_memory_size                          = 128
  lambda_timeout                              = 3
  lambda_reserved_concurrent_executions       = -1
  lambda_logging_config_log_format            = "JSON"
  lambda_logging_config_application_log_level = "INFO"
  lambda_logging_config_shadow_log_level      = "INFO"
  lambda_ephemeral_storage_size               = 512
  lambda_tracing_config_mode                  = "Active"
  lambda_provisioned_concurrent_executions    = -1
  # lambda_image_config_entry_point             = []
  # lambda_image_config_command                 = []
  # lambda_image_config_working_directory       = null
}