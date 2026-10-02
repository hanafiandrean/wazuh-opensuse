# Wazuh All-in-One Installer for openSUSE Leap 16

![OS](https://img.shields.io/badge/OS-openSUSE%20Leap%2016-green)
![Wazuh](https://img.shields.io/badge/Wazuh-4.14-blue)
![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange)
![Automation](https://img.shields.io/badge/Automation-Ansible-red)

Automated installer and deployment tools for running **Wazuh All-in-One** on **openSUSE Leap 16.0**.

This repository provides two installation methods:

1. **Standalone Shell Installer**  
   `install_wazuh_all_in_one_opensuse.sh`

2. **Ansible Playbook Installer**  
   `install_wazuh_full_opensuse.yml`

The purpose of this project is to simplify Wazuh deployment on openSUSE by adding compatibility preparation before installing the official Wazuh stack.

---

# Overview

## What is Wazuh?

Wazuh is an open-source security monitoring platform that provides:

- Security Information and Event Management (SIEM)
- Endpoint Monitoring
- Intrusion Detection
- File Integrity Monitoring
- Vulnerability Detection
- Log Analysis
- Compliance Monitoring


This repository installs a complete Wazuh All-in-One environment:

```
                +----------------+
                | Wazuh Dashboard|
                | HTTPS :443     |
                +-------+--------+
                        |
                        |
                +-------v--------+
                | Wazuh Indexer  |
                | OpenSearch     |
                | HTTPS :9200    |
                +-------+--------+
                        |
                        |
                +-------v--------+
                | Wazuh Manager  |
                | Agent Service  |
                +-------+--------+
                        |
                        |
                +-------v--------+
                | Filebeat       |
                | Log Forwarder  |
                +----------------+
```

---

# Repository Structure

```
.
├── install_wazuh_all_in_one_opensuse.sh
├── install_wazuh_full_opensuse.yml
└── README.md
```

---

# Installation Methods

## 1. Standalone Shell Installer (Recommended)

File:

```
install_wazuh_all_in_one_opensuse.sh
```

## Description

This is the recommended installer for a single openSUSE Leap 16 server.

The script acts as a compatibility wrapper around the official Wazuh installation assistant.

Installation flow:

```
openSUSE Leap 16
        |
        |
Compatibility Preparation
        |
        |
Dependency Configuration
        |
        |
Official Wazuh Installer
        |
        |
Wazuh All-in-One Deployment
```

---

# Shell Installer Features

## 1. Operating System Validation

The script checks:

- Operating system
- Version
- Architecture


Supported target:

```
openSUSE Leap 16.0
x86_64
```

---

## 2. Hardware Pre-Check

Before installation, the script checks:

- CPU
- RAM
- Disk space


Recommended specification:

```
CPU     : 4 Core
RAM     : 8 GB
Storage : 50 GB
```

For testing environment:

```
CPU     : 2 Core
RAM     : 4 GB
```

---

## 3. Safe Reinstallation Protection

The installer does not automatically delete existing Wazuh installation.

It detects:

```
wazuh-indexer
wazuh-manager
wazuh-dashboard
filebeat
```

If an existing installation is found, the installer stops.

To force reinstall:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --force-reinstall
```

---

## 4. openSUSE Compatibility Preparation

The script prepares required dependencies:

- RPM compatibility
- DNF/YUM compatibility
- system packages
- libcap compatibility


This allows the official Wazuh installer to run correctly on openSUSE.

---

## 5. Wazuh RPM Dependency Compatibility

openSUSE uses different package naming compared with other RPM distributions.

The installer creates:

```
libcap-wazuh-compat
```

This package only satisfies RPM dependency checking without replacing the original openSUSE libraries.

---

## 6. Kernel Configuration

The installer applies:

```
vm.max_map_count=262144
```

Required by:

```
Wazuh Indexer / OpenSearch
```

---

## 7. Firewall Configuration

Default ports:

| Port | Service |
|-|-|
| 443/TCP | Wazuh Dashboard |
| 1514/TCP | Agent Communication |
| 1515/TCP | Agent Enrollment |
| 55000/TCP | Wazuh API (optional) |


---

## 8. Official Wazuh Installation

The script downloads and executes:

```
Wazuh Installation Assistant
```

with:

```
All-in-One mode
```

The installer deploys:

```
wazuh-indexer
wazuh-manager
filebeat
wazuh-dashboard
```

---

## 9. Post Installation Validation

After installation, the script verifies:

- Wazuh services
- Indexer HTTPS response
- Dashboard HTTPS response
- Admin authentication


---

# Shell Installer Usage

## Download Repository

```bash
git clone <repository-url>

cd wazuh-opensuse-installer
```

---

## Give Permission

```bash
chmod +x install_wazuh_all_in_one_opensuse.sh
```

---

## Run Installer

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh
```

---

# Shell Installer Options

## Force Reinstall

Overwrite existing installation:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --force-reinstall
```

---

## Ignore Hardware Check

For testing only:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --ignore-hardware
```

---

## Custom Dashboard Port

Default:

```
443
```

Example:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --port 8443
```

---

## Enable Wazuh API Port

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --open-api
```

---

# 2. Ansible Playbook Installer

File:

```
install_wazuh_full_opensuse.yml
```

---

# Description

This method uses Ansible automation to deploy Wazuh remotely.

Architecture:

```
+----------------+
| Ansible PC     |
| Controller     |
+-------+--------+
        |
        |
        SSH
        |
        |
+-------v--------+
| openSUSE VPS   |
| Wazuh Server   |
+----------------+
```

---

# Ansible Features

The playbook performs:

- Stop existing Wazuh services
- Remove old packages
- Clean old configuration
- Install dependencies
- Configure repositories
- Apply compatibility settings
- Configure firewall
- Install Wazuh
- Configure services
- Verify installation


---

# Ansible Usage

Install Ansible:

```bash
sudo zypper install ansible
```

Create inventory:

Example:

```ini
[opensuse_wazuh]

wazuh01 ansible_host=SERVER_IP ansible_user=root
```

Test connection:

```bash
ansible -i inventory.ini opensuse_wazuh -m ping
```

Run installation:

```bash
ansible-playbook \
-i inventory.ini \
install_wazuh_full_opensuse.yml
```

---

# Shell vs Ansible Comparison

| Feature | Shell Installer | Ansible |
|-|-|-|
| Recommended for first installation | ✅ | |
| Single VPS | ✅ | |
| Multiple VPS | | ✅ |
| Automation | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| openSUSE compatibility | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Troubleshooting | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Reusable deployment | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Maintenance | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

# Recommendation

## Single VPS

Use:

```
install_wazuh_all_in_one_opensuse.sh
```

Reason:

- Simple deployment
- No Ansible requirement
- Compatibility fixes included
- Better for first installation


---

## Multiple Server Deployment

Use:

```
install_wazuh_full_opensuse.yml
```

Reason:

- Infrastructure as Code
- Repeatable deployment
- Easier server management


Recommended workflow:

```
First Installation
        |
        v
Shell Installer
        |
        |
Validate Wazuh
        |
        v
Ansible Automation
```

---

# System Requirements

## Minimum

| Component | Requirement |
|-|-|
| OS | openSUSE Leap 16.0 |
| CPU | 2 Core |
| RAM | 4 GB |
| Storage | 50 GB |
| Architecture | x86_64 |
| Access | Root |


## Recommended

| Component | Requirement |
|-|-|
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | 50 GB SSD |

---

# Dashboard Access

After successful installation:

```
https://SERVER-IP
```

Login:

```
Username:
admin
```

Password:

```
Generated automatically
```

The password will be displayed after installation completes.

---

# Service Verification

Check services:

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

# Logs

Installer log:

```
/var/log/wazuh-opensuse-all-in-one.log
```

Wazuh installation log:

```
/var/log/wazuh-install.log
```

---

# Troubleshooting

## Wazuh Indexer

```bash
journalctl -u wazuh-indexer -n 100
```

---

## Wazuh Manager

```bash
journalctl -u wazuh-manager -n 100
```

---

## Dashboard

```bash
journalctl -u wazuh-dashboard -n 100
```

---

# Known Limitations

- Designed specifically for openSUSE Leap 16.0
- x86_64 architecture only
- Future Wazuh versions may require compatibility updates
- Production deployment should be tested first


---

# Conclusion

This repository provides two approaches for deploying Wazuh on openSUSE Leap 16.

Recommended usage:

```
One VPS
    |
    v
install_wazuh_all_in_one_opensuse.sh


Multiple Servers
    |
    v
install_wazuh_full_opensuse.yml
```

The shell installer is recommended as the primary installation method because it includes openSUSE compatibility preparation and uses the official Wazuh installation assistant.

The Ansible playbook is recommended for automated infrastructure management.
