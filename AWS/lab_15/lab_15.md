# Use the AWS CLI to Create an S3 bucket, configure permissions, and upload/download files to/from the bucket. Enable versioning and logging for the bucket.

🚀 A robust Bash script for creating and configuring AWS S3 buckets with logging, versioning, and proper security settings.

## ✨ Features

- 🪣 Creates two S3 buckets (main and logging)
- 📝 Enables server access logging
- 🔄 Configures versioning
- 🏷️ Adds project tags
- 🔒 Sets up proper IAM policies and permissions 
- 👤 Configures Object Ownership settings
- 📊 Manages bucket policies
- 🛡️ Implements security controls
- 📂 Handles file uploads

## ⚙️ Prerequisites

- 💻 AWS CLI installed and configured
- 🔑 AWS credentials with appropriate permissions
- 🐧 Bash shell environment

## 📋 Usage
Download the script `setup_lab15.sh`
```bash
#Make the script executable
chmod +x setup_lab15.sh

#Run the script
./setup_lab15.sh
```

---

## Cleanup
To remove all created resources:
```bash
#Make the script executable
chmod +x cleanup_lab15.sh

#Run the script
./cleanup_lab15.sh
```

---

## 🔍 What the Script Does

### 📦 Creates a Logging Bucket with:
- **👤 Object ownership controls**
- **🔐 Logging service permissions**
- **🏷️ Appropriate tagging**

### 🪣 Creates a Main Bucket with:
- **🔄 Versioning enabled**
- **📝 Server access logging**
- **🔒 Security policies**
- **🏷️ Project tags**

### 📤 Uploads a Test File with Custom Tags

---

## ⚙️ Configuration

🛠️ Default settings can be modified by changing these variables at the start of the script:

- `REGION="us-east-1"`
- `BUCKET_NAME="memo-lab15-bucket-$(date +%s)"`
- `LOG_BUCKET="memo-lab15-logs-${BUCKET_NAME}"`

---

## 📊 Output

🖥️ The script provides colored output showing:

- ✅ Creation status of both buckets
- 📋 Configuration steps
- 📝 Final bucket details
- 📊 Logging setup confirmation

---

## 🛡️ Security Features
- 👤 Object ownership controls
- 🔒 Bucket policies for access control
- 📝 Server access logging
- 🔐 Account-specific conditions
- 🔄 Versioning enabled

---

## 📌 Notes
- 🏷️ Bucket names are automatically generated with timestamps
- ⏰ Logs may take a few hours to appear
- 🌍 Both buckets are created in the same region
- ⚠️ The script exits on any error (`set -e`)

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## ✍️ Author
**King Memo**

## 🙏 Thank You!
Thank you for using this project. Your support and feedback are greatly appreciated!
