variable "ram_share_principals" {
  description = "List of AWS account IDs or Organization/OU ARNs to share the IPAM pool with"
  type        = list(string)
  default     = []
}
