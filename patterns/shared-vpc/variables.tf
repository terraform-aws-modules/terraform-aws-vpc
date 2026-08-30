variable "participant_account_ids" {
  description = "Account IDs that the application subnets are shared with"
  type        = list(string)
  default     = []
}
