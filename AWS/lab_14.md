# create VPC with 2 public subnets, launch 2 EC2s with Nginx and Apache installed using user data, create and configure a Load Balancer to access the 2 Web servers.

# AWS Web Infrastructure Deployment Script

## Overview
This script automates the deployment of a highly available web infrastructure on AWS, featuring load-balanced Nginx and Apache web servers across multiple availability zones.

## Architecture
![Infrastructure Diagram](https://your-image-url.com) <!-- You can add an architecture diagram later -->

### Components
- VPC with 2 public subnets across different AZs
- Internet Gateway for public internet access
- Application Load Balancer
- 2 EC2 instances (Nginx and Apache)
- Security Groups for ALB and EC2 instances

## Prerequisites
- AWS CLI installed and configured
- Appropriate AWS credentials with necessary permissions
- Bash shell environment

## Quick Start
1. Clone this repository
```bash
git clone <repository-url>
cd <repository-name>
