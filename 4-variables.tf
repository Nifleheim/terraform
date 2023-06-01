variable "env" {
  description   = "Environment Name."
  type          = string 
  }

variable "vpc_cidr_block" {
  description   = "CIDR (Classless Inter-Domain Routing)."
  type          = string
  default       = "10.0.0.0/16"
  }

variable "azs" {
  description   = "Availability Zones for Subnets."
  type          = list(string)
}

variable "private_subnets" {
  description   = "CIDR Range for Private Subnets."
  type          = list(string)
}

variable "public_subnets" {
  description   = "CIDR Range for Public Subnets."
  type          = list(string)
}

variable "private_subnet_tags" {
  description   = "Private Subnet Tags."
  type          = map(any)  
}

variable "public_subnet_tags" {
  description   = "Public Subnet Tags."
  type          = map(any)  
}

variable "eks_version" {
  description   = "Desired Kubenetes Master Version."
  type          = string
}

variable "eks_name" {
  description   = "Name of the Cluster."
  type          = string
}

variable "subnet_ids" {
  description   = "List of Subnets ID. Must be in at least two different available az."
  type          = list(string)
}   

variable "node_iam_policies" {
  description   = "List of IAM Policies to attach to EKS-Managed Nodes."
  type          = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description   = "EKS Node Groups."
  type          = map(any)
}

variable "enable_irsa" {
    description = "Determines whether to create an OIDC Provider for EKS."
    type        = bool
    default     = true
}

variable "enable_cluster_autoscaler" {
  description   = "Determines whether to deploy Cluster Autoscaler."
  type          = bool
  default       = false
}

variable "cluster_autoscaler_helm_version" {
  description   = "Cluster Autoscaler Helm Version."
  type          = string
}

variable "openid_provider_arn" {
  description   = "IAM OpenID Connect Provider ARN."
  type          = string
}

