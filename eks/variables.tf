variable "cluster_name" {
    type = string
    description = "The K8S Cluster name"
}

variable "cluster_version" {
    type = string
    description = "K8S API's version"
    default = "1.21"
  
}

variable "vpc_id" {
    type = string
    description = "The VPC ID which the cluster will be deployed to"
  
}

variable "private_subnets_ids" {
  type = list(string)
  description = "The private subnets where the workloads will run in"
}

variable "instance_types" {
    type = list(string)
    description = "EC2 instance types to be used by K8S workers"
  
}

variable "root_volume_size" {
    type = number
    description = "The disk size in GBs to add to the EC2 workers"
  
}

variable "asg_min_size" {
    type = number
    description = "The minimum amount of workers that should be running"
    default = 0
}

variable "asg_desired_capacity" {
    type = number
    description = "The desired amount of workers that should be running"
    default = 0
}

variable "asg_max_size" {
    type = number
    description = "The maximum amount of workers that should be running"
    default = 0
}

variable "on_demand_base_capacity" {
    type = number
    description = "The base capacity of On-Demand EC2 machines"
    default = 0
}

variable "on_demand_percentage_above_base_capacity" {
    type = number
    description = "The percentage of EC2 workers that should run on Spot instances"
    default = 0
}

variable "spot_instance_pools" {
    type = number
    description = "The number of pools that should be used by Spot instances"
    default = 0
}

variable "asg_recreate_on_change" {
    type = bool
    description = "Whether to re-create all the EC2 workers upon changes"
    default = false
}

variable "spot_allocation_strategy" {
    type = string
    description = "The strategy to be used by Spot workloads. Possible values are: 'capacity-optimized' and 'lowest-price'"
    default = "lowest-price"
}