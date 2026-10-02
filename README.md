# Wazuh All-in-One Installer for openSUSE Leap 16

<p align="center">

<img src="https://img.shields.io/badge/OS-openSUSE%20Leap%2016-green">
<img src="https://img.shields.io/badge/Wazuh-4.14-blue">
<img src="https://img.shields.io/badge/Platform-x86__64-orange">
<img src="https://img.shields.io/badge/Shell-Bash-black">
<img src="https://img.shields.io/badge/Automation-Ansible-red">

</p>


## Overview

This repository provides automated deployment tools for installing
**Wazuh All-in-One** on **openSUSE Leap 16**.

Wazuh is an open-source security monitoring platform that provides:

- Security Information and Event Management (SIEM)
- Endpoint Detection and Response (EDR)
- File Integrity Monitoring
- Vulnerability Detection
- Log Analysis
- Compliance Monitoring


Because openSUSE is not the primary target distribution for Wazuh,
additional compatibility preparation is required.

This repository provides several installation approaches:

| Method | File | Purpose |
|---|---|---|
| Recommended Installer | `wazuh-install-V2.sh` | Automated production installation |
| Manual Installer | `install-wazuh.sh` | Manual installation and testing |
| Ansible Deployment | `install_wazuhOpensuse.yml.txt` | Remote automated deployment |


---

# Features

## Wazuh All-in-One Stack

The installer deploys:

```
                 WAZUH ALL-IN-ONE

        +---------------------------+
        |                           |
        |     Wazuh Dashboard       |
        |       HTTPS :443          |
        |                           |
        +-------------+-------------+
                      |
                      |
        +-------------v-------------+
        |                           |
        |     Wazuh Indexer         |
        |     OpenSearch Backend    |
        |       HTTPS :9200         |
        |                           |
        +-------------+-------------+
                      |
                      |
        +-------------v-------------+
        |                           |
        |     Wazuh Manager         |
        |     Security Engine       |
        |                           |
        +-------------+-------------+
                      |
                      |
        +-------------v-------------+
        |                           |
        |       Filebeat            |
        |     Log Forwarder         |
        |                           |
        +---------------------------+
```


---

# Repository Structure

```
wazuh-opensuse-installer/

│
├── README.md
│
├── wazuh-install-V2.sh
│
├── install-wazuh.sh
│
└── install_wazuhOpensuse.yml.txt

```


---

# Installation Methods


# 1. wazuh-install-V2.sh ⭐ Recommended

## Production Installation Script


`wazuh-install-V2.sh` is the primary installer for deploying Wazuh on:

```
openSUSE Leap 16
x86_64
```


This installer provides:

- Operating system validation
- Hardware validation
- Dependency preparation
- openSUSE compatibility handling
- Wazuh installation automation
- Service validation
- Installation logging


---

## Installation Workflow

```
             Start Installer

                    |
                    v

        System Environment Check

                    |
                    v

        Dependency Preparation

                    |
                    v

        openSUSE Compatibility Layer

                    |
                    v

        Wazuh Installation

                    |
                    v

        Service Health Check

                    |
                    v

             System Ready

```


---

# Installation


## 1. Clone Repository

```bash
git clone <repository-url>

cd wazuh-opensuse-installer
```


---

## 2. Give Permission

```bash
chmod +x wazuh-install-V2.sh
```


---

## 3. Run Installer

```bash
sudo ./wazuh-install-V2.sh
```


---

# Recommended Usage Scenario

Use:

```
wazuh-install-V2.sh
```

for:

✅ Fresh VPS installation

✅ Production deployment

✅ Single Wazuh server

✅ openSUSE Leap 16 environment


---

# 2. install-wazuh.sh

## Manual Installation Script


`install-wazuh.sh` provides a manual installation approach.

Unlike the V2 installer, this script installs Wazuh components individually.


Installation flow:

```
Java
 |
 |
Wazuh Indexer
 |
 |
Wazuh Manager
 |
 |
Filebeat
 |
 |
Wazuh Dashboard

```


---

## Features

The script handles:

- Java preparation
- Wazuh package installation
- Certificate generation
- Service configuration
- Dashboard setup


---

## Recommended Usage


Use this script for:

- Testing
- Learning Wazuh architecture
- Debugging installation problems
- Custom modification


---

## Installation


```bash
chmod +x install-wazuh.sh

sudo ./install-wazuh.sh
```


---

# 3. install_wazuhOpensuse.yml.txt

## Ansible Deployment


This playbook provides automated installation using Ansible.

Architecture:

```
+----------------------+
| Administrator PC     |
| Ansible Controller   |
+----------+-----------+
           |
           |
           SSH
           |
           |
+----------v-----------+
| openSUSE Server      |
| Wazuh Deployment     |
+----------------------+

```


---

# Requirements

Install Ansible:

```bash
sudo zypper install ansible
```


---

# Inventory Example

Create:

```
inventory.ini
```


Example:

```ini
[opensuse_wazuh]

wazuh-server ansible_host=SERVER_IP ansible_user=root

```


---

# Run Deployment

Test connection:

```bash
ansible -i inventory.ini opensuse_wazuh -m ping
```


Run installer:

```bash
ansible-playbook \
-i inventory.ini \
install_wazuhOpensuse.yml.txt
```


---

# Comparison

| Feature | V2 Installer | Manual Script | Ansible |
|-|-|-|-|
| Recommended | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Single VPS | ✅ | ✅ | ⚠️ |
| Multiple Server | ⚠️ | ❌ | ✅ |
| Automation | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Debugging | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| openSUSE Support | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Production Usage | ✅ | ⚠️ | ✅ |


---

# Recommended Deployment Strategy


## Single VPS

Recommended:

```
wazuh-install-V2.sh
```


Workflow:

```
Fresh VPS

    |

Run Installer

    |

Validate Services

    |

Connect Agents

```


---

## Multiple Server Environment

Recommended:

```
install_wazuhOpensuse.yml.txt
```


Workflow:

```
Ansible Controller

        |

        |

Multiple openSUSE Servers

        |

        |

Wazuh Deployment

```


---

# System Requirements


## Minimum

| Component | Requirement |
|-|-|
| Operating System | openSUSE Leap 16 |
| Architecture | x86_64 |
| CPU | 2 Core |
| RAM | 4 GB |
| Storage | 50 GB |
| Permission | Root |


---

## Recommended

| Component | Requirement |
|-|-|
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | SSD 50 GB+ |


---

# Network Requirement


Required ports:

| Port | Service |
|-|-|
| 443/TCP | Wazuh Dashboard |
| 1514/TCP | Agent Communication |
| 1515/TCP | Agent Enrollment |
| 55000/TCP | Wazuh API |
| 9200/TCP | Wazuh Indexer |


---

# Dashboard Access


After successful installation:

```
https://SERVER-IP
```


Default account:

```
Username:
admin
```


Password:

```
Generated automatically
```


The installer will display the credential after installation.


---

# Service Verification


Check Wazuh services:

```bash
systemctl status wazuh-indexer

systemctl status wazuh-manager

systemctl status wazuh-dashboard

systemctl status filebeat
```


Expected:

```
active (running)
```


---

# Troubleshooting


## Wazuh Indexer

```bash
journalctl -u wazuh-indexer -n 100
```


## Wazuh Manager

```bash
journalctl -u wazuh-manager -n 100
```


## Dashboard

```bash
journalctl -u wazuh-dashboard -n 100
```


## Filebeat

```bash
journalctl -u filebeat -n 100
```


---

# Logs


Main installation log:

```
/var/log/wazuh-opensuse-all-in-one.log
```


Wazuh installation log:

```
/var/log/wazuh-install.log
```


---

# Known Limitations

- Designed specifically for openSUSE Leap 16
- x86_64 architecture only
- Future Wazuh versions may require compatibility updates
- Always test before production deployment


---

# Roadmap

Future improvements:

- [ ] Automatic backup before reinstall
- [ ] Wazuh uninstall function
- [ ] Agent deployment automation
- [ ] Cluster installation support
- [ ] Web management interface


---

# Author

Beanie Berlingham


---

# License

This project is provided for educational,
testing, and infrastructure deployment purposes.
