# Wazuh All-in-One Installation on openSUSE Leap 16

![OS](https://img.shields.io/badge/OS-openSUSE%20Leap%2016-green)
![Wazuh](https://img.shields.io/badge/Wazuh-4.14-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Automatic installation and configuration of **Wazuh All-in-One** on **openSUSE Leap 16**.

This repository provides two installation methods:

1. **Ansible Playbook Installation**
2. **Manual Shell Script Installation**

The purpose of this project is to simplify Wazuh deployment on openSUSE, because Wazuh officially focuses on distributions such as RHEL-based and Debian-based operating systems.

---

# Overview

Wazuh is an open-source security monitoring platform that provides:

- Security Information and Event Management (SIEM)
- Intrusion Detection
- File Integrity Monitoring
- Vulnerability Detection
- Log Analysis
- Endpoint Monitoring
- Compliance Monitoring


This repository installs the complete Wazuh stack:

```
+-----------------------+
|   Wazuh Dashboard     |
|      HTTPS :443       |
+-----------+-----------+
            |
            |
+-----------v-----------+
|   Wazuh Indexer       |
|     OpenSearch        |
|       :9200           |
+-----------+-----------+
            |
            |
+-----------v-----------+
|   Wazuh Manager       |
|       :1514           |
+-----------+-----------+
            |
            |
+-----------v-----------+
|     Filebeat          |
| Log Forwarder         |
+-----------------------+
```

---

# Repository Structure

```
.
├── install_wazuh_full_opensuse.yml
│
├── install-wazuh.sh
│
└── README.md
```

Description:

| File | Description |
|-|-|
| `install_wazuh_full_opensuse.yml` | Automated Ansible installer |
| `install-wazuh.sh` | Manual installation script |
| `README.md` | Documentation |

---

# Installation Methods

## Method 1 - Ansible Playbook (Recommended)

File:

```
install_wazuh_full_opensuse.yml
```

## Description

The Ansible playbook automates the complete Wazuh installation process.

The playbook handles:

- Removing previous Wazuh installation
- Installing dependencies
- Adding Wazuh repository
- Configuring openSUSE compatibility
- Setting kernel parameters
- Configuring firewall
- Installing Wazuh All-in-One
- Configuring administrator credentials
- Checking service status


---

## Features

### Automatic Cleanup

Before installation, old Wazuh components are removed:

```
wazuh-indexer
wazuh-manager
wazuh-dashboard
filebeat
```

This prevents conflicts from previous failed installations.


### Dependency Installation

Required packages:

```
curl
bash
openssl
python3
sudo
firewalld
rpm-build
libcap
```

---

### Kernel Optimization

The playbook configures:

```
vm.max_map_count=262144
```

Required by Wazuh Indexer/OpenSearch.


---

### Automatic Deployment

Installation process:

```
openSUSE
    |
    |
Ansible Playbook
    |
    |
Wazuh Installer
    |
    |
Wazuh All-in-One
```

---

# Method 2 - Manual Shell Script

File:

```
install-wazuh.sh
```

---

## Description

The shell script installs Wazuh components manually step-by-step.

Installed components:

```
wazuh-indexer
wazuh-manager
filebeat
wazuh-dashboard
```

---

## Features

### openSUSE Compatibility Fix

Creates required systemd compatibility:

```
systemd-sysv-install
```

---

### Java Installation

Installs:

```
Java 21 OpenJDK
```

and configures Wazuh Indexer Java environment.

---

### Certificate Generation

Automatically generates:

```
root-ca.pem
indexer.pem
dashboard.pem
filebeat.pem
```

for secure communication.

---

### Dashboard Installation

Installs Wazuh Dashboard RPM manually.

---

# Comparison

| Feature | Ansible | Shell Script |
|-|-|-|
| Installation automation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Easy deployment | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Troubleshooting | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Maintenance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Production usage | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Development/testing | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Repeatability | ⭐⭐⭐⭐⭐ | ⭐⭐ |

---

# Recommendation

## Recommended: Ansible Playbook

The recommended installation method is:

```
install_wazuh_full_opensuse.yml
```

Reasons:

### 1. Better Maintainability

Configuration is stored as code and can be reused.


### 2. Reproducible Deployment

The same installation process can be repeated on multiple servers.


### 3. Cleaner Installation

The playbook removes previous Wazuh installation before deployment.


### 4. Suitable for Long-Term Usage

Better choice for:

- Campus server
- Company monitoring server
- Security laboratory
- Production environment


---

# When to Use Shell Script?

Use:

```
install-wazuh.sh
```

for:

- Testing
- Learning
- Debugging
- Development


Advantages:

- Easier to understand step-by-step
- Easier to modify manually
- Easier to troubleshoot failed components


---

# System Requirements

Recommended minimum specification:

| Component | Requirement |
|-|-|
| Operating System | openSUSE Leap 16 |
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | 50 GB |
| Java | OpenJDK 21 |
| Internet | Required |
| Privilege | Root access |


---

# Required Ports

Open firewall ports:

| Port | Service |
|-|-|
| 443/TCP | Wazuh Dashboard |
| 1514/TCP | Wazuh Agent Communication |
| 1515/TCP | Agent Enrollment |
| 55000/TCP | Wazuh API |
| 9200/TCP | Wazuh Indexer |


---

# Installation Guide


## Option 1 - Using Ansible


Install Ansible:

```bash
sudo zypper install ansible
```


Run playbook:

```bash
ansible-playbook install_wazuh_full_opensuse.yml
```


---

## Option 2 - Using Shell Script


Give permission:

```bash
chmod +x install-wazuh.sh
```


Run installer:

```bash
sudo ./install-wazuh.sh
```


---

# Service Verification


Check Wazuh services:

```bash
systemctl status wazuh-indexer

systemctl status wazuh-manager

systemctl status wazuh-dashboard

systemctl status filebeat
```

Expected result:

```
active (running)
```

---

# Dashboard Access


After successful installation:


```
URL:
https://SERVER-IP
```


Default credential:

```
Username:
admin


Password:
admin12345
```


---

# Troubleshooting


## Check Indexer

```bash
journalctl -u wazuh-indexer -n 100
```


## Check Manager

```bash
journalctl -u wazuh-manager -n 100
```


## Check Dashboard

```bash
journalctl -u wazuh-dashboard -n 100
```


---

# Known Limitations

- Wazuh is not officially optimized for openSUSE.
- Some compatibility adjustments are required.
- Future Wazuh updates may require script modifications.
- Testing is recommended before production deployment.


---

# Future Improvements

Planned improvements:

- [ ] Add automatic agent deployment
- [ ] Add backup and restore function
- [ ] Add Docker deployment option
- [ ] Improve compatibility testing
- [ ] Add HA cluster deployment


---

# Conclusion

This repository provides two approaches for deploying Wazuh on openSUSE Leap 16.

For general usage:

```
Use Ansible Playbook
```

For testing and debugging:

```
Use Shell Script
```

Recommended workflow:

```
Ansible = Main Installer

Shell Script = Troubleshooting Reference
```

---

# Author

Created for Wazuh deployment experimentation on openSUSE Leap 16.
