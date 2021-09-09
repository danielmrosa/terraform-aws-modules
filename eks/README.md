## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.launch_template_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | The desired amount of workers that should be running | `number` | `0` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The maximum amount of workers that should be running | `number` | `0` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The minimum amount of workers that should be running | `number` | `0` | no |
| <a name="input_asg_recreate_on_change"></a> [asg\_recreate\_on\_change](#input\_asg\_recreate\_on\_change) | Whether to re-create all the EC2 workers upon changes | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The K8S Cluster name | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | K8S API's version | `string` | `"1.21"` | no |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | EC2 instance types to be used by K8S workers | `list(string)` | n/a | yes |
| <a name="input_on_demand_base_capacity"></a> [on\_demand\_base\_capacity](#input\_on\_demand\_base\_capacity) | The base capacity of On-Demand EC2 machines | `number` | `0` | no |
| <a name="input_on_demand_percentage_above_base_capacity"></a> [on\_demand\_percentage\_above\_base\_capacity](#input\_on\_demand\_percentage\_above\_base\_capacity) | The percentage of EC2 workers that should run on Spot instances | `number` | `0` | no |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | The private subnets where the workloads will run in | `list(string)` | n/a | yes |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | The disk size in GBs to add to the EC2 workers | `number` | n/a | yes |
| <a name="input_spot_allocation_strategy"></a> [spot\_allocation\_strategy](#input\_spot\_allocation\_strategy) | The strategy to be used by Spot workloads. Possible values are: 'capacity-optimized' and 'lowest-price' | `string` | `"lowest-price"` | no |
| <a name="input_spot_instance_pools"></a> [spot\_instance\_pools](#input\_spot\_instance\_pools) | The number of pools that should be used by Spot instances | `number` | `0` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID which the cluster will be deployed to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
