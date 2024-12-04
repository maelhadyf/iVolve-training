# Lab 11: Set up Ansible dynamic inventories to automatically discover and manage infrastructure. Use Ansible Galaxy role to install Apache.

## Prerequisites

### Install and configure AWS-CLI
For Linux (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install -y awscli
aws --version
```
After installation, configure the AWS CLI with your credentials:
```bash
aws configure
```
You'll need to provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., us-east-1)
- Default output format (e.g., json)

### Install boto3 ansible in the virtual environment
Let's follow the recommended approach using a Python virtual environment. This is actually a better practice for managing Python packages:
#### 1. install the required packages:
```bash
sudo apt install python3-venv python3-full
```
#### 2. Create a directory for your Ansible project:
```bash
mkdir ansible_project
cd ansible_project
```
#### 3. Create a virtual environment:
```bash
python3 -m venv venv
```
#### 4. Activate the virtual environment:
```bash
source venv/bin/activate
```
#### 5. Now install the required packages in the virtual environment:
```bash
pip install boto3 ansible
```
#### 6. Install the AWS collection for Ansible:
```bash
ansible-galaxy collection install amazon.aws
```
⚠️ **Important Note:**
- To deactivate the virtual environment when you're done:  
```bash  
deactivate  
```  

> **Note:** For future use, remember to:  
> Navigate to your project directory  
> Activate the virtual environment before running any commands:  
> ```bash  
> cd ansible_project  
> source venv/bin/activate  
> ```  





### Install the required collections:
```bash
ansible-galaxy collection install amazon.aws
pip install boto3
```
### Install the Apache role:
```bash
ansible-galaxy install geerlingguy.apache
```


For future use, remember to:

1. Navigate to your project directory

2. Activate the virtual environment before running any commands:
```bash
cd ansible_project
source venv/bin/activate
```

ansible.cfg
```cfg
[defaults]
inventory = ./aws_ec2.yml      #we refer to aws_ec2.yml file here, so we don't need to pass it in commands
host_key_checking = False
remote_user = ubuntu
private_key_file = ./ubuntu.pem
#remote_user = ec2-user
#private_key_file = ./amazon.pem
```


aws_ec2.yml
```yaml
plugin: aws_ec2
regions:
  - us-east-1  # adjust region as needed
filters:
  tag:Environment: ivolve  # adjust tags as needed
keyed_groups:
  - prefix: tag
    key: tags
compose:
  ansible_host: public_ip_address
```

webserver.yml
```yaml
---
- hosts: tag_Role_webserver  # targets hosts tagged with Role:webserver
  become: yes
  vars:
   # ansible_ssh_private_key_file: ./ubuntu.pem
   # ansible_user: ubuntu
    apache_listen_port: 80
    apache_vhosts:
      - servername: "example.com"
        documentroot: "/var/www/html"

  roles:
    - geerlingguy.apache
```



To run the playbook:
```bash
ansible-playbook webserver.yml
```
