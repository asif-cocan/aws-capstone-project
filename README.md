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

## 📸 Screenshots

![ALB]
<img width="616" height="270" alt="image" src="https://github.com/user-attachments/assets/47aaa9f8-0d1c-4bf3-8893-09d644001db7" />
<img width="684" height="241" alt="image" src="https://github.com/user-attachments/assets/561348ea-f87d-4cce-b253-e89c64e8c7ef" />

![EC2]
<img width="1602" height="285" alt="image" src="https://github.com/user-attachments/assets/a99ee3ec-fed0-4c27-a5d9-d42093e85f48" />

![TG]
<img width="1573" height="547" alt="image" src="https://github.com/user-attachments/assets/5cd192d6-979f-44a3-9d80-fff5fa31ddd7" />

![ALB]
<img width="1600" height="283" alt="image" src="https://github.com/user-attachments/assets/86d6518c-1a3b-4cd6-9be9-b75ed4aabe27" />


![RDS]
<img width="1508" height="280" alt="image" src="https://github.com/user-attachments/assets/811cbad3-f073-43dd-bc5b-52d4a5575077" />
