variable "aws_public_ecr_repo_uri" {
    type = string
    sensitive = true  
}

variable "az_subscription_id" {
    type = string
    sensitive = true  
}

variable "az_tenant_id" {
    type = string
    sensitive = true  
}

variable "github_owner" {
    type = string
    sensitive = true  
}

variable "github_repo" {
    type = string
    sensitive = true  
}

variable "github_ref" {
    type = string
    sensitive = true  
}

variable "az_location" {
    type = string
    sensitive = false  
}