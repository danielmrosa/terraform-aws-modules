## How to consume these modules :

I will assume that you already have a VPC, subnets, NAT Gateways or Transit Gateways provisioned. These modules will install a EKS cluster with observability following the three observability pillars using some awesome tools such as Prometheus, Grafana, Grafana Tempo and Loki. Some add-ons will be included soon. Have Fun!


### Step 1 - Just create a main.tf file as below changing the settings according to your environment and needs.

 * cluster_name
 * cluster_version
 * vpc_id
 * private_subnets_ids
 * instance_type
 * root_volume_size
 * asg_min_size
 * asg_desired_capacity
 * asg_max_size
 * bucket
 * key
 * region


### main.tf

```
module "eks" {
    source = "git@github.com:danielmrosa/terraform-aws-modules.git//eks?ref=main"
    cluster_name = "ekscluster"
    cluster_version = "1.21"
    vpc_id = "vpc-xxxxxxx"
    private_subnets_ids = ["subnet-xxxxxxx","subnet-xxxxxxx","subnet-xxxxxxx"]
    instance_types = ["m5.large"]
    root_volume_size = 20
    asg_min_size = 1
    asg_desired_capacity = 1
    asg_max_size = 2
}


terraform {
  backend "s3" {
    bucket = "<your bucket name here>"
    key    = "<your key name>.tfstate"
    region = "your aws region here"
  }
}

provider "aws" {
  region  = "your aws region here"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token

}

terraform {
  required_providers {
    aws = {
      version = "~> 3.2"
      source = "hashicorp/aws"
    }
    kubernetes = {
      version = "~> 2.4"
    }
  }
 }


  ```

  ## Step 2

  ### Run commands :
  
  * terraform init
  * terraform plan
  * terraform apply
