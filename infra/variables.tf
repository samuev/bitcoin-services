variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}
variable "location" {
  type        = string
  description = "Resources location in Azure"
}
variable "cluster_name" {
  type        = string
  description = "AKS name in Azure"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
}
variable "system_node_count" {
  type        = number
  description = "Number of AKS worker nodes"
}
variable "storage_account_name" {
  type        = string
  description = "Storage account name"
}
variable "container_name" {
  type        = string
  description = "Container name"
}
variable "key" {
  type        = string
  description = "Terraform state file name"
}