#!/bin/bash

# This script builds a Docker image and publishes it to a given repository in the AWS ECR service
# Use the --help argument to check the full usage

set -e

AWS_PROFILE="default"
CLUSTER_NAME="qubec-cluster"
DOCKER_FILE="./Dockerfile"
TAG="latest"

usage() {
    cat <<EOF
Publish a script to Amazon Elastic Container Registry given a repository URL. The script assumes that the AWS CLI has already
been configured in the local shell, at least the default profile.

Usage
-----
./ecs_publish_ecr_image.sh --ecr-url ecr_repo_url [--dockerfile /path/to/dockerfile] [--profile <aws_profile>] [--tag <docker_image_tag>] [--help]

A short version of the commands is also available:
./ecs_publish_ecr_image.sh -e ecr_repo_url [-d /path/to/dockerfile] [-p <aws_profile>] [-t <docker_image_tag>] [-h]

