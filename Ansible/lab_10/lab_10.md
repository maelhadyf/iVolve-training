# Lab 10: Organize Ansible playbooks using roles. Create an Ansible role for installing Jenkins, docker, openshift CLI ‘OC’.


## Overview
This Ansible role automates the installation and configuration of essential DevOps tools including Jenkins, Docker, and OpenShift CLI (oc). The role is designed to be modular, maintainable, and follows Ansible best practices.

---

## Features
- 🛠 Automated installation of Jenkins with Java 17
- 🐳 Docker CE installation and configuration
- 🎯 OpenShift CLI (oc) setup
- ⚙️ Modular role structure
- 🔄 Service management with handlers
- ✅ Built-in error handling and validation

---

## Prerequisites
- Ansible 2.9 or higher
- Target systems running Ubuntu/Debian
- Sudo privileges on target systems
- Minimum system requirements:
  - RAM: 2GB (recommended)
  - Disk Space: 10GB
  - Internet connectivity

---

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

---

## Installation

### 1. Clone this repository:
```bash
git clone https://github.com/maelhadyf/iVolve-training.git
cd iVolve-training-main\Ansible\lab_10
```

### 2. Update inventory file with your target hosts

### 3. Run the playbook:
```bash
ansible-playbook install_devops_tools.yml
```

---

## Role Components

### Jenkins Installation
- Installs OpenJDK 17
- Configures Jenkins repository
- Installs and starts Jenkins service
- Sets up proper permissions

### Docker Installation
- Installs Docker CE
- Configures Docker repository
- Sets up Docker service
- Configures user permissions

### OpenShift CLI Installation
- Downloads latest OpenShift client
- Installs in system path
- Configures executable permissions

---

## Configuration

### Default Variables
You can override these variables in your playbook:
```
jenkins_home: /var/lib/jenkins
jenkins_user: jenkins
jenkins_group: jenkins
java_version: openjdk-17-jdk
```

### Handlers
The role includes handlers for:
- Restarting Jenkins service
- Restarting Docker service

---

## Usage Examples

### Basic Usage
```yaml
- hosts: webservers
  become: yes
  roles:
    - devops_tools
```

### Install Specific Components
```yaml
- hosts: webservers
  become: yes
  roles:
    - role: devops_tools
      tags: ['jenkins']
```

---

## Verification

After installation, verify the services:

### Not the easy method
```bash
# Check Jenkins status
systemctl status jenkins

# Verify Docker installation
docker --version

# Verify OpenShift CLI
oc version
```

### Ansible ad-hoc commands to verify the installations
- Verify Jenkins:
```bash
# Check Jenkins service status
ansible all -m service_facts -b | grep jenkins

# Check if Jenkins is running
ansible all -m shell -b -a "systemctl status jenkins"

# Check Jenkins version and status (once Jenkins is running)
ansible all -m uri -a "url=http://localhost:8080/api/json return_content=yes" -b
```

- Verify Docker:
```bash
# Check Docker service status
ansible all -m service_facts -b | grep docker

# Check Docker version
ansible all -m command -b -a "docker --version"

# Check Docker service status
ansible all -m shell -b -a "systemctl status docker"

# Verify Docker can run containers
ansible all -m command -b -a "docker run hello-world"

# Check if user is in Docker group
ansible all -m shell -b -a "groups ${USER} | grep docker"
```

- Verify OpenShift CLI:
```bash
# Check if oc binary exists
ansible all -m stat -b -a "path=/usr/local/bin/oc"

# Check oc version
ansible all -m command -b -a "oc version"

# Check oc binary permissions
ansible all -m shell -b -a "ls -l /usr/local/bin/oc"
```

---

## Troubleshooting Common Issues

### Jenkins fails to start:
- Verify Java installation
- Check system memory
- Review Jenkins logs: ```journalctl -xu jenkins```

### Docker issues:
- Verify group membership
- Check system compatibility
- Review Docker logs: ```journalctl -xu docker```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
