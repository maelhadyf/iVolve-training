# Lab 9: Write an Ansible playbook to install MySQL, create ivovle database, create user with all privileges on ivolve DB. Use Ansible Vault to encrypt sensitive information such as database user password, and incorporate the encrypted data into an Ansible playbook.

## Steps

### 1. create your project directory structure:
```bash
mkdir -p lab_9/{vars,templates}
cd lab_9
```

### 2. Create the vault-encrypted file for sensitive data:
```bash
ansible-vault create vars/mysql_secrets.yml
```
Enter your vault password when prompted!!!!!!,        <!-- for this lab_9, vault password is: 12345 -->
then add these contents:
```yaml
mysql_root_password: "your_secure_root_password"      # mysql_root_password is: 12345
mysql_user: "ivolve"                        #  mysql_user: ivolve
mysql_password: "your_secure_user_password"        # mysql_password is: 12345
mysql_database: "ivolve"        
```

### 3. Create inventory file (inventory):
```
[webservers]
ec2-3-80-206-235.compute-1.amazonaws.com
```

### 4. Create template files:
Create `templates/my.cnf.j2`:
```jinja
[client]
user=root
password={{ mysql_root_password }}

[mysql]
user=root
password={{ mysql_root_password }}
```
Create `templates/mysqld.cnf.j2`:
```jinja
[mysqld]
bind-address = 0.0.0.0
```

### 5. Create the playbook (mysql_setup.yml):
 ```yaml
---
- name: Install and Configure MariaDB on Amazon Linux 2023
  hosts: database_servers
  become: yes
  vars_files:
    - vars/mysql_secrets.yml

  tasks:
    - name: Update all packages
      dnf:
        name: '*'
        state: latest

    - name: Install MariaDB and Python packages
      dnf:
        name:
          - mariadb105-server
          - mariadb105
          - python3-pip
        state: present

    - name: Install PyMySQL using pip
      pip:
        name: PyMySQL
        state: present

    - name: Start and enable MariaDB service
      service:
        name: mariadb
        state: started
        enabled: yes

    - name: Wait for MariaDB to start
      wait_for:
        port: 3306
        timeout: 30

    # Initialize MariaDB root password
    - name: Set MariaDB root password
      mysql_user:
        login_unix_socket: /var/lib/mysql/mysql.sock
        user: root
        password: "{{ mysql_root_password }}"
        host_all: yes
        state: present
        check_implicit_admin: yes

    - name: Create .my.cnf file
      template:
        src: templates/my.cnf.j2
        dest: /root/.my.cnf
        mode: '0600'

    - name: Remove anonymous users
      mysql_user:
        login_unix_socket: /var/lib/mysql/mysql.sock
        name: ''
        host_all: yes
        state: absent

    - name: Remove test database
      mysql_db:
        login_unix_socket: /var/lib/mysql/mysql.sock
        name: test
        state: absent

    - name: Create database
      mysql_db:
        login_unix_socket: /var/lib/mysql/mysql.sock
        name: "{{ mysql_database }}"
        state: present

    - name: Create database user
      mysql_user:
        login_unix_socket: /var/lib/mysql/mysql.sock
        name: "{{ mysql_user }}"
        password: "{{ mysql_password }}"
        priv: "{{ mysql_database }}.*:ALL"
        host: '%'
        state: present

    - name: Configure MariaDB for remote access
      copy:
        dest: /etc/my.cnf.d/mariadb-server.cnf
        content: |
          [mysqld]
          bind-address = 0.0.0.0
          skip-networking = 0
          skip-bind-address
        backup: yes
      notify: restart mariadb

    - name: Check if firewalld is installed
      command: which firewalld
      register: firewalld_check
      ignore_errors: yes
      changed_when: false

    - name: Allow MariaDB in firewall
      firewalld:
        port: 3306/tcp
        permanent: yes
        state: enabled
      when: firewalld_check.rc == 0
      ignore_errors: yes

  handlers:
    - name: restart mariadb
      service:
        name: mariadb
        state: restarted
```

### 6. Run the playbook:
```bash
# Run with vault password prompt
ansible-playbook -i inventory mysql_setup.yml --ask-vault-pass
```

### 7. Verify the installation:
```bash
# Check MariaDB status
ansible database_servers -m shell -a "systemctl status mariadb"

# Check MariaDB version
ansible database_servers -m shell -a "mysql --version"

# Check if PyMySQL is installed
ansible database_servers -m shell -a "pip3 list | grep PyMySQL"
```

---

> **Note:** The following commands should be run on the **remote server** where MySQL is installed.
If you need to test the database connection:
```
# On the remote server
mysql -u root -p
# Enter the password from vault file

# Then try:
mysql> SHOW DATABASES;
mysql> USE ivolve;
mysql> SHOW TABLES;
```

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!

