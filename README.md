# 💻 AWS Scripts Repository! 🛠️

Welcome to the AWS Repository! This repository contains a collection of scripts and resources related to Amazon Web Services (AWS). Whether you're a beginner exploring AWS or an experienced practitioner looking for useful scripts, you'll find valuable content here.

![Readme Header](header.png)

## Table of Contents

1. [Scripts Overview](#scripts-overview)
2. [Other Useful Tools](#other-useful-tools)
2. [Usage](#usage)
3. [Contributing](#contributing)
4. [License](#license)

## Scripts Overview

### CloudFormation

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `delete_stackset.sh`               | Script to delete a stack set.                         | [delete_stackset.sh](./cloudformation/delete_stackset.sh) |

### CloudWatch

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `set_cloudwatch_logs_retention.sh`| Script to set CloudWatch Logs retention.              | [set_cloudwatch_logs_retention.sh](./cloudwatch/set_cloudwatch_logs_retention.sh) |

### CodePipeline

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `slack_notification.sh`            | Script to send Slack notifications from CodePipeline. | [slack_notification.sh](./codepipeline/slack_notification.sh) |

### EC2

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `available_eip.sh`                 | Script to list available Elastic IP addresses.        | [available_eip.sh](./ec2/available_eip.sh)         |
| `delete_all_unattached_volumes.sh` | Script to delete all unattached volumes.              | [delete_all_unattached_volumes.sh](./ec2/delete_all_unattached_volumes.sh) |
| `delete_all_unused_elastic_ips.sh` | Script to delete all unused Elastic IPs.              | [delete_all_unused_elastic_ips.sh](./ec2/delete_all_unused_elastic_ips.sh) |
| `delete_all_unused_keypairs.sh`    | Script to delete all unused key pairs.                | [delete_all_unused_keypairs.sh](./ec2/delete_all_unused_keypairs.sh) |
| `delete_tagged_security_groups.sh` | Script to delete security groups by tag.              | [delete_tagged_security_groups.sh](./ec2/delete_tagged_security_groups.sh) |
| `delete_unused_keypairs.sh`        | Script to delete unused key pairs.                    | [delete_unused_keypairs.sh](./ec2/delete_unused_keypairs.sh) |
| `ebs_capacity_monitor.sh`          | Script to monitor EBS volume capacity.                | [ebs_capacity_monitor.sh](./ec2/ebs_capacity_monitor.sh) |
| `find_all_unattached_volumes.sh`   | Script to find all unattached volumes.                | [find_all_unattached_volumes.sh](./ec2/find_all_unattached_volumes.sh) |
| `find_all_unused_keypairs.sh`      | Script to find all unused key pairs.                 | [find_all_unused_keypairs.sh](./ec2/find_all_unused_keypairs.sh) |
| `find_unused_keypairs.sh`          | Script to find unused key pairs.                      | [find_unused_keypairs.sh](./ec2/find_unused_keypairs.sh) |
| `resize_volume.sh`                 | Script to resize an EBS volume.                       | [resize_volume.sh](./ec2/resize_volume.sh)         |
| `ssh_autoscalinggroup.sh`          | Script to SSH into an Auto Scaling Group instance.    | [ssh_autoscalinggroup.sh](./ec2/ssh_autoscalinggroup.sh) |

### ECS

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `delete_all_inactive_task_definitions.sh` | Script to delete all inactive ECS task definitions. | [delete_all_inactive_task_definitions.sh](./ecs/delete_all_inactive_task_definitions.sh) |
| `publish_ecr_image.sh`            | Script to publish an image to Amazon ECR.            | [publish_ecr_image.sh](./ecs/publish_ecr_image.sh) |

### EFS

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `delete_tagged_efs.sh`             | Script to delete tagged Amazon EFS file systems.     | [delete_tagged_efs.sh](./efs/delete_tagged_efs.sh) |

### General

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `delete_unused_security_groups.sh`| Script to delete unused security groups.             | [delete_unused_security_groups.sh](./general/delete_unused_security_groups.sh) |
| `find_unused_security_groups.sh`  | Script to find unused security groups.               | [find_unused_security_groups.sh](./general/find_unused_security_groups.sh) |
| `multi_account_execution.sh`       | Script for multi-account execution of AWS CLI commands. | [multi_account_execution.sh](./general/multi_account_execution.sh) |
| `tag_secrets.sh`                   | Script to tag AWS Secrets Manager secrets.           | [tag_secrets.sh](./general/tag_secrets.sh) |

### IAM

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `delete_iam_user.sh`               | Script to delete an IAM user.                        | [delete_iam_user.sh](./iam/delete_iam_user.sh)     |
| `key_rotator.sh`                   | Script to rotate IAM access keys.                    | [key_rotator.sh](./iam/key_rotator.sh)             |

### Organizations

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `assign_sso_access_by_ou.sh`       | Script to assign AWS SSO access by OU.               | [assign_sso_access_by_ou.sh](./organizations/assign_sso_access_by_ou.sh) |
| `import_users_to_aws_sso.sh`       | Script to import users to AWS SSO.                   | [import_users_to_aws_sso.sh](./organizations/import_users_to_aws_sso.sh) |
| `list_accounts_by_ou.sh`           | Script to list accounts by OU.                       | [list_accounts_by_ou.sh](./organizations/list_accounts_by_ou.sh) |
| `list_accounts_sso_assignments.sh` | Script to list AWS SSO assignments.                  | [list_accounts_sso_assignments.sh](./organizations/list_accounts_sso_assignments.sh) |
| `remove_sso_access_by_ou.sh`       | Script to remove AWS SSO access by OU.               | [remove_sso_access_by_ou.sh](./organizations/remove_sso_access_by_ou.sh) |

### S3

| Script Name                        | Description                                           | Link                                               |
|------------------------------------|-------------------------------------------------------|----------------------------------------------------|
| `create_tar_file.sh`               | Script to create a tar file from a directory.        | [create_tar_file.sh](./s3/create_tar_file.sh)      |
| `delete_empty_buckets.sh`          | Script to delete empty S3 buckets.                   | [delete_empty_buckets.sh](./s3/delete_empty_buckets.sh) |
| `list_file_older_than_number_of_days.sh` | Script to list files older than a specified number of days in an S3 bucket. | [list_file_older_than_number_of_days.sh](./s3/list_file_older_than_number_of_days.sh) |
| `search_bucket_and_delete.sh`      | Script to search and delete files in an S3 bucket.   | [search_bucket_and_delete.sh](./s3/search_bucket_and_delete.sh) |
| `search_file_in_bucket.sh`         | Script to search for a specific file in an S3 bucket. | [search_file_in_bucket.sh](./s3/search_file_in_bucket.sh) |
| `search_key_bucket.sh`             | Script to search for a specific key in an S3 bucket. | [search_key_bucket.sh](./s3/search_key_bucket.sh) |
| `search_multiple_keys_bucket.sh`   | Script to search for multiple keys in an S3 bucket.  | [search_multiple_keys_bucket.sh](./s3/search_multiple_keys_bucket.sh) |
| `search_subdirectory.sh`           | Script to search for files in a subdirectory of an S3 bucket. | [search_subdirectory.sh](./s3/search_subdirectory.sh) |


## Other Useful Tools

Essential tools widely used by developers and administrators to automate and simplify AWS operations:

### General

- **[Steampipe](https://steampipe.io/)**: Query AWS resources using SQL-like syntax, making it easy to analyze and manage your cloud infrastructure.
- **[AWS Nuke](https://github.com/rebuy-de/aws-nuke)**: Securely remove all resources from an AWS account, ensuring a clean slate for testing or decommissioning.

### CI/CD

- **[Awesome CI](https://github.com/christian-fei/awesome-ci)**: Discover a curated list of Continuous Integration services tailored for AWS deployments, facilitating seamless integration and deployment pipelines.

### EC2

- **[AutoSpotting](https://github.com/AutoSpotting/AutoSpotting)**: Optimize your EC2 infrastructure with this open-source spot market automation tool, reducing costs while maximizing availability and performance.

### ECS

- **[AWS Copilot CLI](https://aws.github.io/copilot-cli/)**: Simplify containerized application development, release, and operation on Amazon ECS and AWS Fargate with this powerful CLI tool.

### IAM

- **[IAM Floyd](https://github.com/redskap/aws-iam-floyd)**: Generate IAM policy statements with ease using a fluent interface, ensuring robust and secure access control.

### Infra as Code

- **[Awesome CDK](https://github.com/kolomied/awesome-cdk)**: Dive into a curated list of resources and projects for working with the AWS Cloud Development Kit (CDK), enabling infrastructure as code (IaC) for your AWS deployments.
- **[Former2](https://former2.com/)**: Effortlessly generate CloudFormation, Terraform, or Troposphere templates from your existing AWS resources, streamlining your infrastructure provisioning process.

### Lambda

- **[AWS Lambda Power Tuning](https://github.com/alexcasalboni/aws-lambda-power-tuning)**: Optimize your AWS Lambda functions for cost and performance using a state machine powered by AWS Step Functions, ensuring efficient resource utilization.

### S3

- **[s3s3mirror](https://github.com/servian/s3s3mirror)**: Mirror content between S3 buckets at lightning speed, perfect for data replication and backup tasks.

### Security

- **[Prowler](https://github.com/toniblyx/prowler)**: Conduct thorough security assessments and audits of your AWS environment, ensuring compliance and readiness for potential threats.

### SSM

- **[aws-gate](https://github.com/99designs/aws-gate)**: Enhance your AWS SSM session management experience with this powerful CLI client, simplifying remote access and administration tasks.

These tools, combined with the scripts in this repository, empower you to take full control of your AWS infrastructure, automate repetitive tasks, and optimize resource utilization.


## Usage

To use any of the scripts in this repository, simply navigate to the respective directory and run the desired script. Make sure to review and customize the scripts as needed before execution.

## Contributing

Contributions to this repository are welcome! If you have scripts or resources related to AWS that you'd like to share, feel free to submit a pull request. Please ensure that your contributions align with the repository's goals and standards.

For more information on contributing, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

This repository is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the contents of this repository for your own projects.
