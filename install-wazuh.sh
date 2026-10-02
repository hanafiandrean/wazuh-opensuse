echo "========================================"
echo " WAZUH INSTALLER"
echo " openSUSE Leap 16 - Manual Script"
echo " by : rexaa A.K.A Beanieberlingham"
echo "========================================"

# =========================================================================
# TAHAP 1: FIX OPENSUSE COMPATIBILITY
# =========================================================================
echo ""
echo "[TAHAP 1] Fix openSUSE compatibility..."

cat > /usr/lib/systemd/systemd-sysv-install << 'EOF'
#!/bin/sh
exit 0
EOF
chmod +x /usr/lib/systemd/systemd-sysv-install
echo "[OK] systemd-sysv-install dummy dibuat"

cat > /etc/sysctl.d/99-wazuh.conf << 'EOF'
vm.max_map_count=262144
EOF
sysctl --system > /dev/null 2>&1
echo "[OK] vm.max_map_count=262144 diterapkan"

# =========================================================================
# TAHAP 2: TAMBAH REPO WAZUH
# =========================================================================
echo ""
echo "[TAHAP 2] Menambahkan repo Wazuh..."

rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
echo "[OK] GPG key Wazuh diimport"

zypper removerepo wazuh 2>/dev/null || true
zypper addrepo -G -n "Wazuh" https://packages.wazuh.com/4.x/yum/ wazuh
zypper --non-interactive refresh wazuh
echo "[OK] Repo Wazuh ditambahkan"

# =========================================================================
# TAHAP 3: INSTALL JAVA
# =========================================================================
echo ""
echo "[TAHAP 3] Install Java 21..."

zypper --non-interactive install -y java-21-openjdk
JAVA_PATH=$(readlink -f /usr/bin/java)
echo "[OK] Java terinstall di: $JAVA_PATH"

# =========================================================================
# TAHAP 4: INSTALL KOMPONEN WAZUH
# =========================================================================
echo ""
echo "[TAHAP 4] Install komponen Wazuh..."

echo "  - Installing wazuh-indexer..."
zypper --non-interactive install -y wazuh-indexer
echo "  [OK] wazuh-indexer terinstall"

echo "  - Installing wazuh-manager..."
zypper --non-interactive install -y wazuh-manager
echo "  [OK] wazuh-manager terinstall"

echo "  - Installing filebeat..."
zypper --non-interactive install -y filebeat
echo "  [OK] filebeat terinstall"

echo "  - Downloading wazuh-dashboard RPM..."
curl -sL https://packages.wazuh.com/4.x/yum/wazuh-dashboard-4.14.5-1.x86_64.rpm -o /tmp/wazuh-dashboard.rpm
echo "  - Installing wazuh-dashboard (bypass libcap)..."
rpm -ivh --nodeps /tmp/wazuh-dashboard.rpm || true
echo "  [OK] wazuh-dashboard terinstall"

# =========================================================================
# TAHAP 5: FIX JAVA BINARY WAZUH-INDEXER
# =========================================================================
echo ""
echo "[TAHAP 5] Fix Java binary wazuh-indexer..."

mv /usr/share/wazuh-indexer/jdk/bin/java /usr/share/wazuh-indexer/jdk/bin/java.bak 2>/dev/null || true
ln -sf "$JAVA_PATH" /usr/share/wazuh-indexer/jdk/bin/java
echo "[OK] Java binary di-symlink ke: $JAVA_PATH"

# =========================================================================
# TAHAP 6: HAPUS PERFORMANCE ANALYZER PLUGIN
# =========================================================================
echo ""
echo "[TAHAP 6] Hapus performance analyzer plugin..."

rm -rf /usr/share/wazuh-indexer/plugins/opensearch-performance-analyzer
echo "[OK] Performance analyzer plugin dihapus"

# =========================================================================
# TAHAP 7: GENERATE SERTIFIKAT
# =========================================================================
echo ""
echo "[TAHAP 7] Generate sertifikat..."

curl -sL https://packages.wazuh.com/4.9/wazuh-certs-tool.sh -o /tmp/wazuh-certs-tool.sh
curl -sL https://packages.wazuh.com/4.9/config.yml -o /tmp/config.yml

sed -i 's/<indexer-node-ip>/127.0.0.1/g' /tmp/config.yml
sed -i 's/<wazuh-manager-ip>/127.0.0.1/g' /tmp/config.yml
sed -i 's/<dashboard-node-ip>/127.0.0.1/g' /tmp/config.yml

chmod +x /tmp/wazuh-certs-tool.sh
bash /tmp/wazuh-certs-tool.sh -A
echo "[OK] Sertifikat berhasil digenerate"

# =========================================================================
# TAHAP 8: KONFIGURASI SERTIFIKAT WAZUH INDEXER
# =========================================================================
echo ""
echo "[TAHAP 8] Konfigurasi sertifikat wazuh-indexer..."

mkdir -p /etc/wazuh-indexer/certs
chmod 500 /etc/wazuh-indexer/certs

cp /tmp/wazuh-certificates/root-ca.pem     /etc/wazuh-indexer/certs/root-ca.pem
cp /tmp/wazuh-certificates/node-1.pem      /etc/wazuh-indexer/certs/indexer.pem
cp /tmp/wazuh-certificates/node-1-key.pem  /etc/wazuh-indexer/certs/indexer-key.pem
cp /tmp/wazuh-certificates/admin.pem       /etc/wazuh-indexer/certs/admin.pem
cp /tmp/wazuh-certificates/admin-key.pem   /etc/wazuh-indexer/certs/admin-key.pem

chmod 400 /etc/wazuh-indexer/certs/*.pem
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs/
echo "[OK] Sertifikat indexer dikonfigurasi"

sed -i 's/^-Xms.*/-Xms1g/' /etc/wazuh-indexer/jvm.options
sed -i 's/^-Xmx.*/-Xmx1g/' /etc/wazuh-indexer/jvm.options
echo "[OK] JVM heap size diset ke 1GB"

# =========================================================================
# TAHAP 9: START WAZUH INDEXER & INIT SECURITY
# =========================================================================
echo ""
echo "[TAHAP 9] Start wazuh-indexer..."

systemctl daemon-reload
systemctl start wazuh-indexer

echo "  Menunggu wazuh-indexer ready di port 9200..."
TIMEOUT=300
ELAPSED=0
while ! nc -z 127.0.0.1 9200 2>/dev/null; do
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    echo "  Menunggu... ($ELAPSED/$TIMEOUT detik)"
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "[ERROR] wazuh-indexer tidak ready dalam $TIMEOUT detik"
        journalctl -xeu wazuh-indexer.service --no-pager | tail -20
        exit 1
    fi
done
echo "[OK] wazuh-indexer ready di port 9200"

echo "  Inisialisasi security plugin..."
/usr/share/wazuh-indexer/bin/indexer-security-init.sh
echo "[OK] Security plugin diinisialisasi"

# =========================================================================
# TAHAP 10: KONFIGURASI FILEBEAT
# =========================================================================
echo ""
echo "[TAHAP 10] Konfigurasi filebeat..."

curl -sL https://packages.wazuh.com/4.9/tpl/wazuh/filebeat/filebeat.yml -o /etc/filebeat/filebeat.yml
sed -i 's/username: .*/username: admin/' /etc/filebeat/filebeat.yml
sed -i 's/password: .*/password: admin/' /etc/filebeat/filebeat.yml
curl -sL https://packages.wazuh.com/4.9/tpl/wazuh/filebeat/wazuh-template.json -o /etc/filebeat/wazuh-template.json
curl -sL https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.4.tar.gz | tar -xz -C /usr/share/filebeat/module

mkdir -p /etc/filebeat/certs
chmod 500 /etc/filebeat/certs
cp /tmp/wazuh-certificates/root-ca.pem     /etc/filebeat/certs/root-ca.pem
cp /tmp/wazuh-certificates/wazuh-1.pem     /etc/filebeat/certs/filebeat.pem
cp /tmp/wazuh-certificates/wazuh-1-key.pem /etc/filebeat/certs/filebeat-key.pem
chmod 400 /etc/filebeat/certs/*.pem
echo "[OK] Filebeat dikonfigurasi"

# =========================================================================
# TAHAP 11: KONFIGURASI SERTIFIKAT WAZUH DASHBOARD
# =========================================================================
echo ""
echo "[TAHAP 11] Konfigurasi sertifikat wazuh-dashboard..."

mkdir -p /etc/wazuh-dashboard/certs
chmod 500 /etc/wazuh-dashboard/certs
cp /tmp/wazuh-certificates/root-ca.pem       /etc/wazuh-dashboard/certs/root-ca.pem
cp /tmp/wazuh-certificates/dashboard.pem     /etc/wazuh-dashboard/certs/dashboard.pem
cp /tmp/wazuh-certificates/dashboard-key.pem /etc/wazuh-dashboard/certs/dashboard-key.pem
chmod 400 /etc/wazuh-dashboard/certs/*.pem
chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs/
echo "[OK] Sertifikat dashboard dikonfigurasi"

# =========================================================================
# TAHAP 12: START SEMUA SERVICE
# =========================================================================
echo ""
echo "[TAHAP 12] Start semua service..."

systemctl start wazuh-manager
echo "  [OK] wazuh-manager started"

systemctl start filebeat
echo "  [OK] filebeat started"

systemctl start wazuh-dashboard
echo "  [OK] wazuh-dashboard started"

echo "  Menunggu dashboard ready di port 443..."
ELAPSED=0
while ! nc -z 127.0.0.1 443 2>/dev/null; do
    sleep 5
    ELAPSED=$((ELAPSED + 5))
    if [ $ELAPSED -ge 120 ]; then
        echo "[WARN] Dashboard belum ready dalam 120 detik"
        break
    fi
done

# =========================================================================
# TAHAP 13: CEK STATUS AKHIR
# =========================================================================
echo ""
echo "========================================"
echo " STATUS AKHIR INSTALASI"
echo "========================================"
for svc in wazuh-indexer wazuh-manager wazuh-dashboard filebeat; do
    STATUS=$(systemctl is-active $svc 2>/dev/null)
    echo "  $svc: $STATUS"
done

IP=$(ip a | grep "inet " | grep -v 127 | awk '{print $2}' | cut -d'/' -f1 | head -1)
echo ""
echo "========================================"
echo " WAZUH BERHASIL DIINSTALL!"
echo " URL     : https://$IP"
echo " Username: admin"
echo " Password: admin"
echo "========================================"
