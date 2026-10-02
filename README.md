# Wazuh All-in-One Installer for openSUSE Leap 16

![OS](https://img.shields.io/badge/OS-openSUSE%20Leap%2016-green)
![Wazuh](https://img.shields.io/badge/Wazuh-4.14-blue)
![Architecture](https://img.shields.io/badge/Architecture-x86__64-orange)
![Automation](https://img.shields.io/badge/Automation-Ansible-red)


Repository ini menyediakan beberapa metode instalasi **Wazuh All-in-One** pada **openSUSE Leap 16**.

Wazuh secara resmi lebih banyak digunakan pada distribusi Linux seperti RHEL-based dan Debian-based. Oleh karena itu, instalasi pada openSUSE membutuhkan beberapa penyesuaian kompatibilitas.

Repository ini menyediakan 3 metode deployment:

1. **Standalone Compatibility Installer**
2. **Manual Shell Installer**
3. **Ansible Automated Installer**

---

# Wazuh Components

Semua installer bertujuan melakukan deployment komponen berikut:

```
+----------------------+
| Wazuh Dashboard      |
| HTTPS :443           |
+----------+-----------+
           |
           |
+----------v-----------+
| Wazuh Indexer        |
| OpenSearch :9200     |
+----------+-----------+
           |
           |
+----------v-----------+
| Wazuh Manager        |
| Agent Communication  |
+----------+-----------+
           |
           |
+----------v-----------+
| Filebeat             |
| Log Forwarder        |
+----------------------+
```

---

# Repository Structure

```
.
├── install_wazuh_all_in_one_opensuse.sh
├── install-wazuh.sh
├── install_wazuh_full_opensuse.yml
└── README.md
```

---

# Installation Methods Overview

| File | Method | Recommended Usage |
|-|-|-|
| `install_wazuh_all_in_one_opensuse.sh` | Compatibility Wrapper | ⭐ Recommended VPS Installation |
| `install-wazuh.sh` | Manual Installer | Testing / Debugging |
| `install_wazuh_full_opensuse.yml` | Ansible Playbook | Multiple Server Deployment |

---

# 1. install_wazuh_all_in_one_opensuse.sh

## Recommended Installer

File:

```
install_wazuh_all_in_one_opensuse.sh
```

---

## Description

Ini adalah installer utama untuk openSUSE Leap 16.

Script ini berfungsi sebagai compatibility wrapper yang melakukan persiapan environment openSUSE sebelum menjalankan installer resmi Wazuh.

Flow:

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
Wazuh All-in-One
```

---

## Features

### OS Validation

Melakukan pengecekan:

- Operating System
- Version
- Architecture


Target:

```
openSUSE Leap 16.0
x86_64
```

---

### Hardware Check

Melakukan pengecekan:

- CPU
- RAM
- Storage


Recommended:

```
CPU     : 4 Core
RAM     : 8 GB
Storage : 50 GB
```

---

### Safe Reinstallation

Installer tidak langsung menghapus instalasi lama.

Jika ditemukan:

```
wazuh-indexer
wazuh-manager
wazuh-dashboard
filebeat
```

installer akan berhenti.

Untuk reinstall:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --force-reinstall
```

---

### Compatibility Preparation

Melakukan:

- Dependency preparation
- DNF/YUM compatibility
- RPM compatibility
- libcap compatibility
- Kernel configuration


---

### Official Wazuh Installer

Menggunakan installer resmi Wazuh untuk deployment:

```
wazuh-indexer
wazuh-manager
filebeat
wazuh-dashboard
```

---

## Usage

```bash
chmod +x install_wazuh_all_in_one_opensuse.sh

sudo ./install_wazuh_all_in_one_opensuse.sh
```

---

## Optional Parameters

Force reinstall:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --force-reinstall
```

Ignore hardware check:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --ignore-hardware
```

Custom dashboard port:

```bash
sudo ./install_wazuh_all_in_one_opensuse.sh --port 8443
```

---

# 2. install-wazuh.sh

## Manual Installer

File:

```
install-wazuh.sh
```

---

## Description

Script ini merupakan installer manual yang melakukan instalasi Wazuh secara bertahap.

Berbeda dengan installer utama, script ini tidak menggunakan seluruh proses official installer.

Komponen diinstall secara manual:

```
Java
 |
Wazuh Indexer
 |
Wazuh Manager
 |
Filebeat
 |
Dashboard
```

---

## Features

### OpenSUSE Compatibility Fix

Membuat compatibility:

```
systemd-sysv-install
```

---

### Java Configuration

Install:

```
Java 21 OpenJDK
```

dan mengatur Java untuk Wazuh Indexer.

---

### Certificate Generation

Melakukan generate:

```
root-ca.pem
indexer.pem
dashboard.pem
filebeat.pem
```

---

### Dependency Bypass

Dashboard menggunakan:

```
rpm --nodeps
```

untuk melewati dependency yang tidak kompatibel.

---

## Advantages

✅ Mudah dimodifikasi

✅ Mudah troubleshooting

✅ Cocok untuk belajar struktur Wazuh

✅ Kontrol instalasi lebih detail


## Limitations

❌ Tidak seaman installer utama

❌ Kurang cocok production

❌ Maintenance lebih manual


---

## Usage

```bash
chmod +x install-wazuh.sh

sudo ./install-wazuh.sh
```

---

# 3. install_wazuh_full_opensuse.yml

## Ansible Installer

File:

```
install_wazuh_full_opensuse.yml
```

---

## Description

Playbook Ansible untuk melakukan deployment Wazuh melalui remote server.

Architecture:

```
Ansible Controller
        |
        |
        SSH
        |
        |
openSUSE Server
        |
        |
Wazuh Installation
```

---

## Features

Playbook melakukan:

- Stop service lama
- Cleanup instalasi sebelumnya
- Install dependency
- Configure repository
- Configure firewall
- Install Wazuh
- Configure service
- Validate installation


---

## Requirements

Install Ansible:

```bash
sudo zypper install ansible
```

---

## Inventory Example

```
[opensuse_wazuh]

wazuh01 ansible_host=SERVER_IP ansible_user=root
```

---

## Run

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

# Comparison

| Feature | Compatibility Installer | Manual Script | Ansible |
|-|-|-|-|
| File | all_in_one.sh | install-wazuh.sh | .yml |
| Recommended | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Single VPS | ✅ | ✅ | ⚠️ |
| Multiple Server | ⚠️ | ❌ | ✅ |
| Automation | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| Debugging | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| openSUSE Support | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

# Recommendation

## 1 VPS openSUSE

Gunakan:

```
install_wazuh_all_in_one_opensuse.sh
```

Karena:

- paling stabil
- compatibility fix lengkap
- menggunakan official Wazuh installer
- cocok untuk server baru


---

## Testing / Development

Gunakan:

```
install-wazuh.sh
```

Karena:

- lebih mudah dimodifikasi
- mudah melihat proses instalasi
- cocok untuk eksperimen


---

## Banyak Server

Gunakan:

```
install_wazuh_full_opensuse.yml
```

Karena:

- automation
- repeatable deployment
- infrastructure as code


---

# System Requirements

Minimum:

| Component | Requirement |
|-|-|
| OS | openSUSE Leap 16.0 |
| Architecture | x86_64 |
| CPU | 2 Core |
| RAM | 4 GB |
| Storage | 50 GB |
| Access | Root |


Recommended:

| Component | Requirement |
|-|-|
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | 50 GB SSD |

---

# Dashboard Access

After installation:

```
https://SERVER-IP
```

Username:

```
admin
```

Password:

```
Generated automatically
```

---

# Service Check

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

Main installer:

```
/var/log/wazuh-opensuse-all-in-one.log
```

Wazuh installer:

```
/var/log/wazuh-install.log
```

---

# Troubleshooting

Indexer:

```bash
journalctl -u wazuh-indexer -n 100
```

Manager:

```bash
journalctl -u wazuh-manager -n 100
```

Dashboard:

```bash
journalctl -u wazuh-dashboard -n 100
```

---

# Known Limitations

- Target utama openSUSE Leap 16.0
- Architecture x86_64
- Future Wazuh update mungkin membutuhkan adjustment
- Testing disarankan sebelum production

---

# Conclusion

Repository ini menyediakan tiga pendekatan instalasi Wazuh pada openSUSE Leap 16.

Recommended workflow:

```
New VPS
   |
   v
install_wazuh_all_in_one_opensuse.sh


Testing / Research
   |
   v
install-wazuh.sh


Multiple Server Deployment
   |
   v
install_wazuh_full_opensuse.yml
```

```
Recommended Installer:

install_wazuh_all_in_one_opensuse.sh
```
