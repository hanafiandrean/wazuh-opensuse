# Wazuh All-in-One Deployment Suite for openSUSE Leap 16

<p align="center">

<img src="https://img.shields.io/badge/OS-openSUSE%20Leap%2016-green">
<img src="https://img.shields.io/badge/Wazuh-4.14-blue">
<img src="https://img.shields.io/badge/Architecture-x86__64-orange">
<img src="https://img.shields.io/badge/Shell-Bash-black">
<img src="https://img.shields.io/badge/Automation-Ansible-red">

</p>


## Overview

**Wazuh All-in-One Deployment Suite** is a collection of installation tools
designed to deploy **Wazuh Security Platform** on **openSUSE Leap 16**.

Wazuh consists of several central components:

- Wazuh Manager
- Wazuh Indexer
- Wazuh Dashboard
- Filebeat

These components work together to provide:

- SIEM monitoring
- Endpoint security monitoring
- Log analysis
- File integrity monitoring
- Vulnerability detection
- Security event management

Reference:
https://documentation.wazuh.com/current/quickstart.html


---

# Project Purpose

The official Wazuh installation assistant primarily targets supported Linux
distributions. This repository provides additional installation approaches
for openSUSE environments.

The project provides three deployment methods:

| File | Method | Target User |
|-|-|-|
| `wazuh-install-V2.sh` | Automated Installer | Beginner / Production |
| `install-wazuh.sh` | Manual Installer | Advanced User |
| `install_wazuhOpensuse.yml.txt` | Ansible Deployment | Administrator / Multiple Server |


---

# Repository Structure

```
wazuh-opensuse-installer/

├── README.md

├── wazuh-install-V2.sh
│   └── Main production installer

├── install-wazuh.sh
│   └── Manual installation script

└── install_wazuhOpensuse.yml.txt
    └── Ansible automation playbook

```


---

# Wazuh Architecture

```
                    WAZUH PLATFORM


              +----------------+
              |    Dashboard   |
              |    HTTPS :443  |
              +-------+--------+
                      |
                      |
              +-------v--------+
              |    Indexer     |
              |   OpenSearch   |
              |    :9200       |
              +-------+--------+
                      |
                      |
              +-------v--------+
              |    Manager     |
              | Security Engine|
              +-------+--------+
                      |
                      |
              +-------v--------+
              |    Filebeat    |
              | Log Forwarder  |
              +----------------+

```


---

# Installation Methods


# 1. wazuh-install-V2.sh ⭐ Recommended


## Overview

`wazuh-install-V2.sh` is the main installer included in this repository.

This script is designed for users who want a simple and automated deployment
of Wazuh All-in-One on openSUSE Leap 16.


Installation workflow:

```
System Check

      |

Dependency Preparation

      |

openSUSE Compatibility Setup

      |

Wazuh Installation

      |

Service Validation

      |

Dashboard Ready

```


---

## Features

### Automatic Environment Validation

Checks:

- Operating system
- Architecture
- Hardware resources
- Required dependencies


---

### Automated Installation

Automatically installs:

```
✓ Wazuh Indexer

✓ Wazuh Manager

✓ Filebeat

✓ Wazuh Dashboard

```


---

### Post Installation Validation

After installation:

- Checks service status
- Validates Wazuh components
- Confirms dashboard availability


---

## Advantages

✅ Easy installation

✅ Recommended for new VPS

✅ Less manual configuration

✅ Suitable for production deployment

✅ Faster deployment


---

## Disadvantages

❌ Less customization

❌ User has less control over each installation stage

❌ Troubleshooting requires checking generated logs


---

## Recommended For

Use this script when:

- Installing Wazuh on a fresh VPS
- Deploying a single Wazuh server
- Wanting a quick deployment


---

## Installation


Clone repository:

```bash
git clone <repository-url>

cd wazuh-opensuse-installer
```


Give permission:

```bash
chmod +x wazuh-install-V2.sh
```


Run:

```bash
sudo ./wazuh-install-V2.sh
```


---

# 2. install-wazuh.sh


# Manual Installation Script


## Overview

`install-wazuh.sh` provides a manual installation approach.

Unlike V2 installer, this script installs Wazuh components individually.

Installation flow:

```
Java Setup

    |

Wazuh Indexer

    |

Wazuh Manager

    |

Filebeat

    |

Wazuh Dashboard

```


---

## Features

The script provides manual control over:

- Package installation
- Certificate preparation
- Service configuration
- Component deployment


---

## Advantages

✅ More transparent installation process

✅ Easier debugging

✅ Suitable for learning Wazuh architecture

✅ Easier customization


---

## Disadvantages

❌ Requires more Linux knowledge

❌ More manual troubleshooting

❌ Higher chance of configuration mistakes

❌ Not recommended for inexperienced users


---

## Recommended For

Use this script when:

- Developing/testing Wazuh
- Learning internal components
- Modifying installation process


---

## Installation


```bash
chmod +x install-wazuh.sh


sudo ./install-wazuh.sh

```


---

# 3. install_wazuhOpensuse.yml.txt


# Ansible Automated Deployment


## Overview

This playbook allows administrators to deploy Wazuh remotely using Ansible.


Architecture:

```

Administrator PC

        |

        |

     Ansible

        |

        |

       SSH

        |

        |

openSUSE Wazuh Server

```


---

## Advantages

✅ Infrastructure as Code

✅ Repeatable deployment

✅ Suitable for multiple servers

✅ Centralized management

✅ Easier maintenance


---

## Disadvantages

❌ Requires Ansible knowledge

❌ Requires SSH configuration

❌ Overkill for one VPS


---

## Recommended For

Use this method when:

- Managing multiple VPS
- Enterprise environment
- Need automated deployment


---

## Requirements


Install Ansible:

```bash
sudo zypper install ansible
```


Create inventory:

```ini
[opensuse_wazuh]

wazuh01 ansible_host=SERVER_IP ansible_user=root

```


Run:

```bash
ansible-playbook \
-i inventory.ini \
install_wazuhOpensuse.yml.txt

```


---

# Method Comparison


| Feature | V2 Installer | Manual Script | Ansible |
|-|-|-|-|
| Easy Installation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Customization | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Production Use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Single VPS | ✅ | ✅ | ⚠️ |
| Multiple VPS | ⚠️ | ❌ | ✅ |
| Debugging | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Automation | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |


---

# Which One Should I Use?


## Single VPS

Recommended:

```
wazuh-install-V2.sh
```

Reason:

- Fast
- Automated
- Minimal configuration


---

## Learning / Development

Recommended:

```
install-wazuh.sh
```

Reason:

- More transparent
- Easier modification
- Better understanding of components


---

## Multiple Server Deployment

Recommended:

```
install_wazuhOpensuse.yml.txt
```

Reason:

- Automation
- Repeatable deployment
- Central management


---

# System Requirements


## Minimum

| Resource | Requirement |
|-|-|
| OS | openSUSE Leap 16 |
| CPU | 2 Core |
| RAM | 4 GB |
| Storage | 50 GB |
| Architecture | x86_64 |
| Permission | Root |


---

## Recommended

| Resource | Requirement |
|-|-|
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | SSD 50GB+ |


---

# Network Ports


| Port | Function |
|-|-|
| 443 | Dashboard |
| 1514 | Agent Communication |
| 1515 | Agent Enrollment |
| 55000 | Wazuh API |
| 9200 | Indexer |


---

# Dashboard Access


After successful installation:

```
https://SERVER-IP
```


Default user:

```
admin
```


Password:

```
Generated automatically
```


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

# Troubleshooting


## Indexer

```bash
journalctl -u wazuh-indexer -n 100
```


## Manager

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


Installer log:

```
/var/log/wazuh-opensuse-all-in-one.log
```


Wazuh log:

```
/var/log/wazuh-install.log
```


---

# Author


**Beanie Berlingham**

Project:

**Wazuh openSUSE Deployment Suite**


---

# License

This project is intended for educational,
testing, and infrastructure deployment purposes.
