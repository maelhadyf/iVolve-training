# Create AWS account, set billing alarm, create 2 IAM groups (admin-developer), admin group has admin permissions, developer group only access to ec2,  create admin-1 user with console access only and enable MFA & admin-2-prog user with cli access only and list all users and groups using commands, create dev-user with programmatic and console access and try to access EC2 and S3 from dev user.

## Overview

A comprehensive Bash script for setting up AWS IAM users, groups, and billing alerts.

---

## Features

### IAM Setup
- **Groups**
  - `memo-lab12-admin-developer`: Administrator access
  - `memo-lab12-developer`: EC2 full access

- **Users**
  - `memo-lab12-admin-1`: Console access with MFA
  - `memo-lab12-admin-2-prog`: Programmatic access
  - `memo-lab12-dev-user`: Both console and programmatic access

### Security
- Multi-Factor Authentication (MFA) setup
- Forced password change at first login
- Secure access key generation
- Principle of least privilege

### Monitoring
- Billing alarm setup
- Email notifications for billing thresholds
- CloudWatch metrics integration
- SNS topic for alerts

---

## Prerequisites
- AWS CLI installed and configured
- AWS account with administrative access
- Bash shell environment
- Virtual MFA device (Google Authenticator or similar)

---

## Usage
Download the script `setup_lab12.sh`
```bash
#Make the script executable
chmod +x setup_lab12.sh

#Run the script
./setup_lab12.sh
```
- **Follow the prompts:**
  - Enter email for billing alerts
  - Scan MFA QR code
  - Provide two consecutive MFA codes

---

## Cleanup
To remove all created resources:
```bash
#Make the script executable
chmod +x cleanup_lab14.sh

#Run the script
./cleanup_lab14.sh
```

---

## Configuration Details

This document outlines the configuration details for IAM users, groups, MFA settings, billing alarms, and security best practices in AWS.

### Users and Access

The following table provides an overview of the IAM users, their access type, group membership, and whether MFA is required for login.

| **User**        | **Access Type** | **Group**         | **MFA Required** |
|-----------------|-----------------|-------------------|------------------|
| admin-1         | Console         | admin-developer   | Yes              |
| admin-2-prog    | CLI             | admin-developer   | No               |
| dev-user        | Both            | developer         | No               |

### Billing Alarm

A billing alarm has been set up to monitor AWS costs. The following configuration applies:

- **Threshold**: $10 USD
- **Period**: 6 hours
- **Metric**: EstimatedCharges
- **Action**: Email notification

### Post-Setup Tasks

After completing the setup, the following immediate actions and security best practices should be followed:

#### Immediate Actions

- **Confirm SNS subscription via email**: Ensure that the SNS subscription for billing alerts is confirmed.
- **Change temporary passwords**: All newly created users should change their temporary passwords.
- **Store access keys securely**: Store access keys in a secure location, such as a password manager.
- **Test MFA login**: Verify that MFA is enabled and functional for users who require it.

#### Security Best Practices

- **Rotate access keys regularly**: Rotate programmatic access keys every 90 days or as needed.
- **Monitor billing alerts**: Regularly check AWS billing alarms to ensure there are no unexpected charges.
- **Review group memberships**: Periodically review IAM group memberships to ensure users have appropriate access.
- **Keep MFA device secure**: Ensure that MFA devices are stored securely and are not shared.

---

### Script Output

Upon completing the setup, the following information will be provided:

1. **IAM user and group listings**: A listing of IAM users and their respective groups.
2. **Access keys for programmatic access**: Information on access keys for programmatic access, securely stored.
3. **Group membership details**: A summary of group memberships for each user.
4. **Setup confirmation**: A final confirmation that all tasks have been completed, including MFA testing and access keys rotation.


---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!





