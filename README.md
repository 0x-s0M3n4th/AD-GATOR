# 🐊 AD-GATOR

### Azure-Based Active Directory Attack–Defense Lab

---

## Overview

**AD-GATOR** is a fully cloud-based Active Directory (AD) attack–defense lab built on Microsoft Azure using Terraform.

The project simulates a real-world enterprise environment where:

* Infrastructure is deployed using Infrastructure as Code (IaC)
* Active Directory is configured from scratch
* Attacks are executed from an attacker machine
* Defensive monitoring is implemented using Wazuh

---

**If you want to directly start without any BS go here [quick-start](https://github.com/0x-s0M3n4th/AD-GATOR/blob/main/Quick-start.md)**

## Objectives

* Automate infrastructure deployment using Terraform
* Build and configure an enterprise-grade Active Directory environment
* Simulate real-world attack scenarios (Red Team)
* Monitor and analyze attacks (Blue Team)
* Understand identity-based security in cloud environments

---

## Architecture

The lab is deployed inside an Azure Virtual Network (VNet) with segmented subnets:

* **Domain Subnet** → Domain Controller (Windows Server 2022)
* **Workstation Subnet** → Domain-joined Windows 10 machine
* **Attacker Subnet** → Kali Linux machine
* **Monitoring Subnet** → Wazuh server

Security is enforced using:

* Network Security Groups (NSGs)
* Controlled inbound/outbound access

---

## Lab Components

| Role              | Description                         |
| ----------------- | ----------------------------------- |
| Domain Controller | Hosts Active Directory, DNS         |
| Workstation       | Domain-joined client machine        |
| Attacker          | Kali Linux for offensive operations |
| Defender          | Wazuh for logging & detection       |

---

## Tech Stack

* Terraform (Infrastructure as Code)
* Microsoft Azure (Cloud Platform)
* Active Directory (Identity Management)
* Kali Linux (Offensive Security)
* Wazuh (Security Monitoring)

---

## 📂 Project Structure

```
terraform/      → Infrastructure code (Azure resources)
scripts/        → Automation scripts (PowerShell/Bash)
docs/           → Step-by-step documentation
diagrams/       → Architecture diagrams
```

---


## Skills Demonstrated

* Active Directory Deployment & Administration
* Cloud Infrastructure Design (Azure)
* Infrastructure as Code (Terraform)
* Red Team Techniques (AD Attacks)
* Blue Team Monitoring & Detection

---

## Project Status

* [x] Project Initialization
* [x] Network Infrastructure
* [x] Domain Controller Deployment
* [x] Active Directory Deployment
* [x] Domain Join (Workstation)
* [x] Attack Simulation
* [ ] Monitoring & Detection

---

## Legal Disclaimer

This project is intended for **educational and ethical security research purposes only**.

Any misuse of the information or techniques demonstrated in this project is strictly discouraged.
The author is not responsible for any illegal activities performed using this knowledge.

---

## 📌 Author

0x-s0M3n4th

---
