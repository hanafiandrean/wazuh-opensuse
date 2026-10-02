# Wazuh All-in-One Installer for openSUSE Leap 16

Repository ini menyediakan installer **Wazuh All-in-One** untuk **openSUSE Leap 16** dengan dua metode deployment:

1. **Ansible Playbook**
2. **Shell Script Installer**

Wazuh secara resmi lebih banyak digunakan pada distribusi Linux seperti RHEL-based dan Debian-based. Karena itu, instalasi pada openSUSE membutuhkan beberapa penyesuaian compatibility agar komponen Wazuh dapat berjalan dengan baik.

Repository ini menyediakan dua pendekatan dengan tujuan berbeda:

- **Ansible Playbook** → automation dan deployment terstruktur
- **Shell Script** → compatibility workaround dan instalasi langsung


---

# Wazuh Components Installed

Kedua installer akan melakukan deployment komponen:

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
├── install_wazuh_full_opensuse.yml
├── install-wazuh.sh
└── README.md
```

---

# Installation Methods

## 1. Ansible Playbook

File:

```
install_wazuh_full_opensuse.yml
```

## Overview

Metode ini menggunakan Ansible untuk melakukan instalasi Wazuh secara otomatis.

Playbook melakukan:

- Menghentikan service Wazuh lama
- Menghapus instalasi sebelumnya
- Membersihkan konfigurasi lama
- Install dependency openSUSE
- Konfigurasi repository
- Menyesuaikan environment RPM
- Konfigurasi kernel parameter
- Membuka firewall
- Menjalankan installer Wazuh
- Konfigurasi password administrator
- Melakukan pengecekan service


## Kelebihan

✅ Automation penuh

✅ Deployment dapat diulang

✅ Konfigurasi terdokumentasi dalam bentuk code

✅ Cocok untuk beberapa server

✅ Maintenance lebih mudah


## Kekurangan

❌ Masih bergantung pada installer resmi Wazuh

❌ Compatibility fix lebih terbatas

❌ Jika installer utama gagal, debugging lebih kompleks


---

# 2. Shell Script Installer

File:

```
install-wazuh.sh
```

## Overview

Metode ini melakukan instalasi Wazuh secara langsung menggunakan shell script dengan beberapa compatibility adjustment khusus openSUSE.

Script melakukan:

- Membuat compatibility file systemd
- Konfigurasi kernel
- Menambahkan repository Wazuh
- Install Java 21
- Install Wazuh Indexer
- Install Wazuh Manager
- Install Filebeat
- Install Dashboard
- Generate certificate
- Konfigurasi service


## Compatibility Fix

Script ini memiliki beberapa workaround agar Wazuh dapat berjalan pada openSUSE:

### Systemd Compatibility

Membuat:

```
/usr/lib/systemd/systemd-sysv-install
```


### RPM Dependency Bypass

Dashboard menggunakan:

```
rpm -ivh --nodeps
```

untuk melewati dependency package yang berbeda antara openSUSE dan distribusi RPM lainnya.


### Java Compatibility

Menggunakan Java sistem:

```
java-21-openjdk
```

untuk Wazuh Indexer.


## Kelebihan

✅ Lebih cocok untuk openSUSE

✅ Memiliki compatibility workaround lebih lengkap

✅ Tidak bergantung penuh pada installer all-in-one

✅ Lebih mudah troubleshooting karena proses terlihat tahap demi tahap


## Kekurangan

❌ Tidak sefleksibel Ansible

❌ Kurang cocok untuk deployment banyak server

❌ Perlu perhatian saat upgrade versi Wazuh


---

# Comparison

| Feature | Ansible (.yml) | Shell Script (.sh) |
|---|---|---|
| Automation | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| OpenSUSE compatibility | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Troubleshooting | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Deployment banyak server | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| Maintenance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Dependency bypass | ❌ | ✅ |
| Manual control | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |


---

# Recommendation

## Recommended for openSUSE Leap 16

Untuk instalasi pertama pada openSUSE Leap 16:

```
install-wazuh.sh
```

lebih direkomendasikan.


Alasan:

- openSUSE membutuhkan beberapa compatibility workaround
- script melakukan bypass dependency yang biasanya menjadi masalah
- instalasi komponen dilakukan secara langsung
- lebih mudah menemukan error ketika instalasi gagal


---

## Recommended for Deployment Management

Gunakan:

```
install_wazuh_full_opensuse.yml
```

apabila:

- server sudah berhasil diuji
- ingin deployment berulang
- ingin menggunakan automation
- mengelola banyak host


Workflow yang disarankan:

```
Testing / Initial Installation
            |
            v
 install-wazuh.sh
            |
            v
 Verify Wazuh Works
            |
            v
 Convert Deployment
            |
            v
 Ansible Playbook
```

---

# Requirements

Minimum:

| Component | Requirement |
|-|-|
| OS | openSUSE Leap 16 |
| CPU | 4 Core |
| RAM | 8 GB |
| Storage | 50 GB |
| Architecture | x86_64 |
| Internet | Required |
| Access | Root privilege |


---

# Running Installation


## Option 1 - Shell Script

```bash
chmod +x install-wazuh.sh

sudo ./install-wazuh.sh
```


---

## Option 2 - Ansible

Install Ansible:

```bash
sudo zypper install ansible
```


Run:

```bash
ansible-playbook install_wazuh_full_opensuse.yml
```


---

# Default Dashboard Access

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
admin
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


Expected:

```
active (running)
```


---

# Troubleshooting

## Indexer Problem

```bash
journalctl -u wazuh-indexer
```


## Manager Problem

```bash
journalctl -u wazuh-manager
```


## Dashboard Problem

```bash
journalctl -u wazuh-dashboard
```


## Filebeat Problem

```bash
journalctl -u filebeat
```


---

# Known Limitations

- Wazuh does not officially target openSUSE as the primary platform.
- Some RPM compatibility adjustments are required.
- Future Wazuh versions may require script updates.
- Test before production deployment.


---

# Conclusion

This repository provides two approaches to deploy Wazuh on openSUSE Leap 16.

Use:

```
install-wazuh.sh
```

for first installation and compatibility testing.


Use:

```
install_wazuh_full_opensuse.yml
```

for automated deployment and long-term management.


Recommended approach:

```
Shell Script → Validate Installation

Ansible → Manage Deployment
```
