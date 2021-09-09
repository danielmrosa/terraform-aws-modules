resource "random_id" "launch_template_name" {
  byte_length = 8
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnets         = var.private_subnets_ids
  enable_irsa     = true
  write_kubeconfig = false
  worker_groups_launch_template = [{
    name                    = random_id.launch_template_name.hex
    override_instance_types = var.instance_types
    root_encrypted          = true
    root_volume_size        = var.root_volume_size
    asg_min_size                             = var.asg_min_size
    asg_desired_capacity                     = var.asg_desired_capacity
    on_demand_base_capacity                  = var.on_demand_base_capacity
    on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity // 100% Spot
    asg_max_size                             = var.asg_max_size
    spot_instance_pools                      = var.spot_instance_pools
    asg_recreate_on_change   = var.asg_recreate_on_change
    spot_allocation_strategy = var.spot_allocation_strategy
    kubelet_extra_args = "--node-labels=node.kubernetes.io/lifecycle=`curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle`"
  }]
  tags = {
    env = "Dev"
  }
}
