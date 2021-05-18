# automatedchub
# Blackduck Support automation Scrips

A few scripts to automate specific deployment tasks 


# Resetting Blackduck server 

deploy_local.sh Replaces current stack with Blackduck and Alert versions of your choosing:

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `--version, -v` | Blackduck Version to install | `null` |
| `--alert-version, -a` | Blackduck Alert version to install | `null` |
| `--name, -n` | name of the new stack | `null` |

example:

deploy_local.sh -v=2021.2.1 -a=6.4.4 -n=hub


## Generating AWS machine with deployed Blackduck instance

Requires the use of AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html and having CLI keys to operate AWS resources.

aws_instance.sh will auto generate ec2 instance and intiate the blackduck deployment invoking initialize_aws_instance.sh remotely passing the relevant parameters

aws_instance.sh

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `--create, -c` | Creates a new EC2 instance | `null` |
| `--delete, -d` | Deletes an existing instance referenced by name | `null` |
| `--name, -n` | name of the instance to operate | `null` |
| `--key-name, -k` | name of key resource to access the instance remotely | `null` |
| `--version, -v` | Blackduck Version to install | `master` |
| `--alert-version, -a` | Blackduck Alert version to install | `6.4.4` |
| `--owner, -o` | Owner tag | `null` |
| `--instance-size, -i` | AWS instance size | `c5.4xlarge` |
| `--ebs-size, -e` | size for the EBS volume in GB | `100` |


if running initialize_aws_instance.sh individually

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `--version, -v` | Blackduck Version to install | `null` |
| `--alert-version, -a` | Blackduck Alert version to install | `null` |

## Deploy K8 cluster using kops

Required kops: https://kops.sigs.k8s.io/getting_started/install/
Requires the use of AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html and having CLI keys to operate AWS resources.
Requires creating an S3 bucket
Additional docs: https://kubernetes.io/docs/setup/production-environment/tools/kops/

## Deploy BD using helm on a K8 cluster

initialize_kops_cluster.sh will install the necesary elements and deploy a blackduck server on a K8 cluster deployed using kops 
