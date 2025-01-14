variable "system_name" {
  description = "System name"
  type        = string
  default     = "slc"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "connect_handler_lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the connect handler"
  type        = string
}

variable "connect_handler_lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the connect handler"
  type        = string
}

variable "disconnect_handler_lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the disconnect handler"
  type        = string
}

variable "disconnect_handler_lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the disconnect handler"
  type        = string
}

variable "sendmessage_handler_lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the sendmessage handler"
  type        = string
}

variable "sendmessage_handler_lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the sendmessage handler"
  type        = string
}

variable "default_handler_lambda_function_qualified_arn" {
  description = "Lambda function qualified ARN of the default handler"
  type        = string
}

variable "default_handler_lambda_function_invoke_arn" {
  description = "Lambda function invoke ARN of the default handler"
  type        = string
}
