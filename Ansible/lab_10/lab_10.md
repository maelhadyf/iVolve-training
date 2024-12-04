# Lab 10: Organize Ansible playbooks using roles. Create an Ansible role for installing Jenkins, docker, openshift CLI ‘OC’.


## Overview
This Ansible role automates the installation and configuration of essential DevOps tools including Jenkins, Docker, and OpenShift CLI (oc). The role is designed to be modular, maintainable, and follows Ansible best practices.

## Features
- 🛠 Automated installation of Jenkins with Java 17
- 🐳 Docker CE installation and configuration
- 🎯 OpenShift CLI (oc) setup
- ⚙️ Modular role structure
- 🔄 Service management with handlers
- ✅ Built-in error handling and validation

## Prerequisites
- Ansible 2.9 or higher
- Target systems running Ubuntu/Debian
- Sudo privileges on target systems
- Minimum system requirements:
  - RAM: 2GB (recommended)
  - Disk Space: 10GB
  - Internet connectivity

## Project Structure
```
project_root/
│
├── install_devops_tools.yml          # Main playbook
├── ansible.cfg
├── inventory
│
└── roles/
    └── devops_tools/                 # Role name
        ├── defaults/                 # Default variables
        │   └── main.yml
        │
        ├── handlers/                 # Handlers
        │   └── main.yml
        │
        ├── tasks/                    # Tasks
        │   ├── main.yml             # Main tasks file
        │   ├── dependencies.yml      # Dependencies tasks
        │   ├── jenkins.yml          # Jenkins installation tasks
        │   ├── docker.yml           # Docker installation tasks
        │   └── openshift.yml        # OpenShift CLI tasks
        │
        └── vars/                     # Variables
            └── main.yml
```


## Installation
1. Clone this repository:
```bash
git clone <repository-url>
cd <repository-directory>
```
