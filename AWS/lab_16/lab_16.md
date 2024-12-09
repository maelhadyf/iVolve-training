# 🚀 Build a serverless application using AWS Lambda, API Gateway, and DynamoDB.

Automate your AWS serverless API deployment with a single script! 

![2024-12-09_13-41](https://github.com/user-attachments/assets/deb3a0c6-bb5e-4a95-a4a2-e6f4a90cbad3)


## 🎯 Overview

This magical script sets up your complete serverless infrastructure:
- 📦 DynamoDB table
- 👮 IAM role
- ⚡ Lambda function
- 🌐 API Gateway
- 🧪 Automated testing

## ✨ Features

- 🤖 Fully automated deployment
- 🛡️ Built-in error handling
- 🧹 Automatic cleanup
- 📝 Detailed logging
- ✅ Comprehensive testing
- 🔄 Resource state validation

## 🔧 Prerequisites

- 💻 AWS CLI (v2 or higher)
- 🔑 Configured AWS credentials
- 🐧 Bash shell environment

## 📋 Usage
Download the script `setup_lab16.sh`
```bash
#Make the script executable
chmod +x setup_lab16.sh

#Run the script
./setup_lab16.sh
```

---

## Cleanup
To remove all created resources:
```bash
#Make the script executable
chmod +x cleanup_lab16.sh

#Run the script
./cleanup_lab16.sh
```

---

# 🏗️ What Gets Created

This script automatically provisions and manages AWS resources. Here’s what gets created:

| **Service**       | **Purpose**          |
|-------------------|----------------------|
| 📦 **DynamoDB**    | Data storage         |
| ⚡ **Lambda**      | Backend logic        |
| 🌐 **API Gateway**| REST API endpoints   |
| 👮 **IAM Role**    | Security permissions |

## 🧪 Testing
The script automatically tests the following operations:

- ✨ **Create items**
- 📖 **Read items**
- 📝 **Update items**
- 🗑️ **Delete items**

## 🛠️ Maintenance
The script also handles resource cleanup:

- 🗑️ **Delete API Gateway**
- 🗑️ **Remove Lambda function**
- 🗑️ **Delete DynamoDB table**
- 🗑️ **Remove IAM role**

## 🚨 Error Handling
The script watches for the following errors:

- ⚠️ **Missing AWS CLI**
- ⚠️ **Invalid credentials**
- ⚠️ **Failed resource creation**
- ⚠️ **API test failures**

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
