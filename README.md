# 🚀 AWS Capstone Project (Terraform)

## 📌 Overview
This project demonstrates a production-ready AWS infrastructure built using Terraform. It includes a highly available and scalable architecture with load balancing, auto scaling, and a private database.

---

## 🧱 Architecture

User → ALB → Auto Scaling EC2 → RDS (MySQL)

---

## ⚙️ Services Used

- Amazon VPC
- EC2 (Auto Scaling)
- Application Load Balancer
- Amazon RDS (MySQL)
- Terraform

---

## 🚀 Features

- Multi-AZ high availability
- Infrastructure as Code using Terraform
- Auto Scaling based architecture
- Secure RDS in private subnets
- Automated EC2 setup using user_data

---

## 🛠️ How to Run

```bash
terraform init
terraform apply


