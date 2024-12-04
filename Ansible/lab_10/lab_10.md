# Lab 10: Organize Ansible playbooks using roles. Create an Ansible role for installing Jenkins, docker, openshift CLI ‘OC’.

## Project Structure
project_root/
│
├── install_devops_tools.yml          # Main playbook
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

