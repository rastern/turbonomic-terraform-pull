# Turbonomic Terraform Integration Strategies

The Turbonomic platform provides advanced analytic capabilities across the
entire visible IT estate, from infrastructure to applications, and from initial
placement to ongoing multi-dimensional resource rightsizing. Bringing this
analysis into Terraform generally takes on one of two strategies: push from
Trubonomic upon action generation, or pull from Terraform to update scripts
before or during an *apply* procedure.

Examples contained within this repository demonstrate some of the ways in which
one might pull information from Turbonomic in order to adjust the Terraform
managed infrastructure based on Turbonomic analysis.


## Examples

### AWS
* [EC2 Instance Resizing](https://github.com/rastern/turbonomic-terraform-pull/tree/master/examples/aws/ec2/README.md)

### Azure
* [Compute Instance Resizing](https://github.com/rastern/turbonomic-terraform-pull/blob/master/examples/azure/vm/README.md)
