variable "env" {
  description   = "Environment Name."
  type          = string 
  default       = "cilsy"
}

variable "vpc_cidr_block" {
  description   = "CIDR (Classless Inter-Domain Routing)."
  type          = string
  default       = "10.0.0.0/16"
}

variable "azs" {
  description   = "Availability Zones for Subnets."
  type          = list(string)
  default       = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "private_subnets" {
  description   = "CIDR Range for Private Subnets."
  type          = list(string)
  default       = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "public_subnets" {
  description   = "CIDR Range for Public Subnets."
  type          = list(string)
  default       = ["10.0.64.0/19", "10.0.96.0/19"]
}

variable "private_subnet_tags" {
  description   = "Private Subnet Tags."
  type          = map(any)  
  default = {
    "kubernetes.io/role/internal-elb"       = "1"
    "kubernetes.io/cluster/cilsy-final"     = "owned"
  }
}

variable "public_subnet_tags" {
  description   = "Public Subnet Tags."
  type          = map(any)  
  default = {
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/cluster/cilsy-final"     = "owned"
  }
}
variable "subnet_ids" {
  description   = "List of Subnets ID. Must be in at least two different available az."
  type          = list(string)
  default       = [
      "aws_subnet.private_ap_southeast_2a.id",
      "aws_subnet.private_ap_southeast_2b.id",
      "aws_subnet.public_ap_southeast_2a.id",
      "aws_subnet.public_ap_southeast_2b.id"
      ]
} 


variable "eks_version" {
  description   = "Desired Kubenetes Master Version."
  type          = string
  default       = "1.26"
}

variable "eks_name" {
  description   = "Name of the Cluster."
  type          = string
  default       = "final"
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
  default       = {
    sydney      = {
            capacity_type   = "ON_DEMAND"
            instance_types  = ["t3.medium"]
            scaling_config  = {
                desired_size    = 5
                max_size        = 6
                min_size        = 4
            }
        }
  }
}

variable "enable_irsa" {
    description = "Determines whether to create an OIDC Provider for EKS."
    type        = bool
    default     = true
}

variable "enable_cluster_autoscaler" {
  description   = "Determines whether to deploy Cluster Autoscaler."
  type          = bool
  default       = true
}

variable "cluster_autoscaler_helm_version" {
  description   = "Cluster Autoscaler Helm Version."
  type          = string
  default       = "9.28.0"
}

variable "openid_provider_arn" {
  description   = "IAM OpenID Connect Provider ARN."
  type          = string
  default       = "aws_iam_openid_connect_provider.this[0].arn"
}

