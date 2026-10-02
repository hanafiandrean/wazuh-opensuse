#!/usr/bin/env bash
# Standalone Wazuh all-in-one installer for openSUSE Leap 16.0 (x86_64)
# Compatibility-oriented wrapper around the official Wazuh 4.14 installation assistant.
#
# Default behavior is NON-DESTRUCTIVE: if an existing Wazuh installation is detected,
# this script stops and requires an explicit --force-reinstall.

set -Eeuo pipefail
umask 077

SCRIPT_NAME="$(basename "$0")"
WAZUH_SERIES="4.14"
WAZUH_INSTALL_URL="https://packages.wazuh.com/${WAZUH_SERIES}/wazuh-install.sh"
WORKDIR="/root/wazuh-install"
LOGFILE="/var/log/wazuh-opensuse-all-in-one.log"
DASHBOARD_PORT=443
FORCE_REINSTALL=0
IGNORE_HARDWARE=0
OPEN_API=0
NO_FIREWALL=0

usage() {
  cat <<USAGE
Usage: sudo ./${SCRIPT_NAME} [options]

Installs Wazuh all-in-one on openSUSE Leap 16.0 using the official Wazuh
installation assistant, with openSUSE compatibility preparation.

Options:
  --force-reinstall   Allow the official Wazuh installer overwrite mode (-o).
                      WARNING: existing Wazuh configuration/data can be removed.
  --ignore-hardware   Pass -i to the official installer to bypass its minimum
                      hardware check. Not recommended unless you understand the risk.
  --port PORT         Dashboard HTTPS port (default: 443).
  --open-api          If firewalld is already running, also open TCP/55000.
  --no-firewall       Do not modify firewalld rules.
  -h, --help          Show this help.

Examples:
  sudo ./${SCRIPT_NAME}
  sudo ./${SCRIPT_NAME} --port 8443
  sudo ./${SCRIPT_NAME} --force-reinstall
USAGE
}

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

warn() {
  printf '[%s] WARNING: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

die() {
  printf '[%s] ERROR: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
  exit 1
}

on_error() {
  local rc=$?
  local line=${1:-unknown}
  local cmd=${2:-unknown}
  printf '\n[%s] ERROR: command failed (rc=%s) at line %s: %s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$rc" "$line" "$cmd" >&2
  printf '[%s] See log: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$LOGFILE" >&2
  exit "$rc"
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

while (($# > 0)); do
  case "$1" in
    --force-reinstall)
      FORCE_REINSTALL=1
      shift
      ;;
    --ignore-hardware)
      IGNORE_HARDWARE=1
      shift
      ;;
    --open-api)
      OPEN_API=1
      shift
      ;;
    --no-firewall)
      NO_FIREWALL=1
      shift
      ;;
    --port)
      (($# >= 2)) || die "--port requires a numeric argument"
      DASHBOARD_PORT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1. Use --help."
      ;;
  esac
done

[[ "$DASHBOARD_PORT" =~ ^[0-9]+$ ]] || die "Dashboard port must be numeric"
((DASHBOARD_PORT >= 1 && DASHBOARD_PORT <= 65535)) || die "Dashboard port must be between 1 and 65535"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  die "Run this installer as root: sudo ./${SCRIPT_NAME}"
fi

command -v zypper >/dev/null 2>&1 || die "zypper not found; this installer is for openSUSE"
command -v rpm >/dev/null 2>&1 || die "rpm not found"

mkdir -p "$(dirname "$LOGFILE")"
touch "$LOGFILE"
chmod 600 "$LOGFILE"
exec > >(tee -a "$LOGFILE") 2>&1

log "Starting ${SCRIPT_NAME}"
log "Log file: ${LOGFILE}"

# ---------- OS / architecture validation ----------
[[ -r /etc/os-release ]] || die "/etc/os-release not found"
# shellcheck disable=SC1091
source /etc/os-release

case "${ID:-}" in
  opensuse-leap|opensuse)
    ;;
  *)
    die "Unsupported OS ID '${ID:-unknown}'. This installer targets openSUSE Leap 16.0."
    ;;
esac

if [[ "${VERSION_ID:-}" != "16.0" ]]; then
  die "Detected openSUSE version '${VERSION_ID:-unknown}'. This installer is intentionally limited to Leap 16.0."
fi

ARCH="$(uname -m)"
[[ "$ARCH" == "x86_64" ]] || die "Unsupported architecture '$ARCH'. This installer currently targets x86_64 only."

log "Detected OS: ${PRETTY_NAME:-openSUSE Leap 16.0} (${ARCH})"

# ---------- Hardware preflight ----------
CPU_COUNT="$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 1)"
MEM_MB="$(awk '/MemTotal:/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
ROOT_FREE_MB="$(df -Pm / | awk 'NR==2 {print $4}')"

log "Hardware: CPU=${CPU_COUNT}, RAM=${MEM_MB} MiB, free root disk=${ROOT_FREE_MB} MiB"

if ((CPU_COUNT < 2 || MEM_MB < 3700)); then
  if ((IGNORE_HARDWARE == 0)); then
    die "Hardware is below the Wazuh installer's practical minimum (~2 CPU / 4 GiB RAM). Re-run with --ignore-hardware only for a disposable test VM."
  fi
  warn "Hardware minimum check will be bypassed because --ignore-hardware was requested."
fi

if ((CPU_COUNT < 4 || MEM_MB < 7800 || ROOT_FREE_MB < 50000)); then
  warn "System is below Wazuh's recommended quickstart sizing for small deployments (4 vCPU, 8 GiB RAM, 50 GB storage). Installation may still work for a lab."
fi

# ---------- Existing installation guard ----------
existing=()
for pkg in wazuh-indexer wazuh-manager wazuh-dashboard filebeat; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    existing+=("$pkg")
  fi
done

for path in /var/ossec /etc/wazuh-indexer /etc/wazuh-dashboard; do
  if [[ -e "$path" ]]; then
    existing+=("$path")
  fi
done

if ((${#existing[@]} > 0)); then
  if ((FORCE_REINSTALL == 0)); then
    printf 'Existing Wazuh-related installation detected:\n'
    printf '  - %s\n' "${existing[@]}"
    die "Refusing to overwrite existing data. Use --force-reinstall only if destroying/replacing the existing Wazuh installation is intended."
  fi
  warn "Existing Wazuh installation detected. Official overwrite mode (-o) will be used. Existing Wazuh data/configuration may be removed."
fi

# ---------- Install openSUSE prerequisites ----------
log "Refreshing openSUSE repositories..."
zypper --non-interactive refresh

base_packages=(
  bash curl ca-certificates tar gzip openssl hostname iproute2 systemd
  systemd-sysvcompat python3 sudo rpm-build libcap2 libcap-progs procps
  lsof coreutils grep gawk sed findutils util-linux
)

log "Installing required openSUSE packages..."
zypper --non-interactive install --no-recommends "${base_packages[@]}"

# Wazuh's unattended installer currently expects a yum-style package manager.
# Leap 16 provides DNF/YUM compatibility packages. Install them without creating
# a fake openSUSE repository.
log "Installing DNF/YUM compatibility tooling..."
if ! zypper --non-interactive install --no-recommends dnf yum; then
  warn "The 'yum' compatibility package could not be installed as a package; retrying with dnf only."
  zypper --non-interactive install --no-recommends dnf
fi

command -v dnf >/dev/null 2>&1 || die "dnf is unavailable after installation"

if ! command -v yum >/dev/null 2>&1; then
  warn "yum command is unavailable; installing a minimal /usr/local/sbin/yum -> dnf compatibility wrapper."
  cat > /usr/local/sbin/yum <<'YUMWRAP'
#!/usr/bin/env bash
exec /usr/bin/dnf "$@"
YUMWRAP
  chmod 0755 /usr/local/sbin/yum
fi

command -v yum >/dev/null 2>&1 || die "yum compatibility command is still unavailable"

# The official Wazuh RPM repository writer expects these standard RPM/YUM paths.
mkdir -p /etc/yum.repos.d /etc/pki/rpm-gpg
chmod 0755 /etc/yum.repos.d /etc/pki/rpm-gpg

# systemd-sysvcompat should provide the helper rather than replacing a system file
# with a dummy script.
if [[ ! -x /usr/lib/systemd/systemd-sysv-install ]]; then
  die "systemd-sysv-install helper is missing even after installing systemd-sysvcompat"
fi

# ---------- Network preflight ----------
log "Checking access to Wazuh package infrastructure..."
curl --fail --silent --show-error --location --retry 3 --connect-timeout 10 \
  --max-time 30 --range 0-1023 -o /dev/null "$WAZUH_INSTALL_URL"

# ---------- libcap compatibility ----------
# Wazuh's RPM dependency scan checks the RPM package name 'libcap'. openSUSE uses
# the real runtime/tool packages libcap2 and libcap-progs. If rpm -q libcap does
# not resolve, create a tiny metadata compatibility package that DEPENDS on those
# real packages; it does not replace the actual shared library or setcap/getcap.
prepare_libcap_compat() {
  if rpm -q libcap >/dev/null 2>&1; then
    log "RPM dependency name 'libcap' is already satisfied."
    return 0
  fi

  rpm -q libcap2 >/dev/null 2>&1 || die "libcap2 is not installed"
  rpm -q libcap-progs >/dev/null 2>&1 || die "libcap-progs is not installed"
  command -v setcap >/dev/null 2>&1 || die "setcap is unavailable after installing libcap-progs"

  local cap_version rpmroot specfile compat_rpm
  cap_version="$(rpm -q --qf '%{VERSION}' libcap2 2>/dev/null || echo '2.73')"
  cap_version="${cap_version//[^0-9A-Za-z._+~-]/_}"
  rpmroot="${WORKDIR}/rpmbuild"
  specfile="${rpmroot}/SPECS/libcap-wazuh-compat.spec"

  rm -rf "$rpmroot"
  mkdir -p "$rpmroot"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

  cat > "$specfile" <<SPEC
Name:           libcap
Version:        ${cap_version}
Release:        1.wazuhcompat
Summary:        Wazuh RPM dependency compatibility metadata for openSUSE
License:        MIT
BuildArch:      noarch
Requires:       libcap2
Requires:       libcap-progs
Provides:       libcap = %{version}-%{release}

%description
Compatibility metadata package for Wazuh on openSUSE. The actual libcap
runtime and tools are provided by openSUSE packages libcap2 and libcap-progs.

%prep

%build

%install
mkdir -p %{buildroot}/usr/share/doc/libcap-wazuh-compat
cat > %{buildroot}/usr/share/doc/libcap-wazuh-compat/README <<'DOC'
This package only satisfies the RPM package-name dependency expected by the
Wazuh RPM installer on openSUSE. Real libcap functionality is supplied by
libcap2 and libcap-progs.
DOC

%files
/usr/share/doc/libcap-wazuh-compat/README
SPEC

  log "Building libcap compatibility RPM..."
  rpmbuild -bb --define "_topdir ${rpmroot}" "$specfile"

  compat_rpm="$(find "$rpmroot/RPMS" -type f -name 'libcap-*.noarch.rpm' -print -quit)"
  [[ -n "$compat_rpm" && -f "$compat_rpm" ]] || die "libcap compatibility RPM was not generated"

  rpm -Uvh --replacepkgs "$compat_rpm"
  rpm -q libcap >/dev/null 2>&1 || die "RPM dependency name 'libcap' is still not satisfied"
  log "Installed compatibility RPM: $(rpm -q libcap)"
}

mkdir -p "$WORKDIR"
chmod 0700 "$WORKDIR"
prepare_libcap_compat

# ---------- Kernel setting required by the indexer ----------
log "Configuring vm.max_map_count..."
cat > /etc/sysctl.d/99-wazuh.conf <<'SYSCTL'
vm.max_map_count=262144
SYSCTL
chmod 0644 /etc/sysctl.d/99-wazuh.conf
sysctl -w vm.max_map_count=262144 >/dev/null

# ---------- Firewall (only if already active) ----------
configure_firewall() {
  if ((NO_FIREWALL == 1)); then
    log "Skipping firewall configuration (--no-firewall)."
    return 0
  fi

  if ! command -v firewall-cmd >/dev/null 2>&1; then
    warn "firewalld is not installed. No firewall rules were changed."
    return 0
  fi

  if ! firewall-cmd --state >/dev/null 2>&1; then
    warn "firewalld is installed but not running. It will not be started automatically, to avoid disrupting remote access."
    return 0
  fi

  local ports=("${DASHBOARD_PORT}/tcp" "1514/tcp" "1515/tcp")
  if ((OPEN_API == 1)); then
    ports+=("55000/tcp")
  fi

  for port in "${ports[@]}"; do
    firewall-cmd --permanent --add-port="$port" >/dev/null
  done
  firewall-cmd --reload >/dev/null
  log "Updated firewalld ports: ${ports[*]}"
}
configure_firewall

# ---------- Download official Wazuh installation assistant ----------
INSTALLER="${WORKDIR}/wazuh-install.sh"
log "Downloading official Wazuh ${WAZUH_SERIES} installation assistant..."
curl --fail --silent --show-error --location \
  --retry 5 --retry-delay 2 --retry-all-errors \
  -o "$INSTALLER" "$WAZUH_INSTALL_URL"
chmod 0700 "$INSTALLER"

[[ -s "$INSTALLER" ]] || die "Downloaded Wazuh installer is empty"
head -n 1 "$INSTALLER" | grep -Eq '^#!.*(bash|sh)' || die "Downloaded file does not look like a shell installer"
INSTALLER_SHA256="$(sha256sum "$INSTALLER" | awk '{print $1}')"
log "Downloaded installer SHA-256: ${INSTALLER_SHA256}"

# Fail early if Wazuh changes/removes an option this wrapper relies on.
INSTALLER_HELP="$(bash "$INSTALLER" -h 2>&1 || true)"
for required_opt in "-a" "-v" "-id"; do
  grep -Fq -- "$required_opt" <<<"$INSTALLER_HELP" || die "Downloaded Wazuh installer does not advertise required option ${required_opt}"
done
if ((DASHBOARD_PORT != 443)); then
  grep -Fq -- "-p" <<<"$INSTALLER_HELP" || die "Downloaded Wazuh installer does not advertise the dashboard port option (-p)"
fi
if ((IGNORE_HARDWARE == 1)); then
  grep -Fq -- "-i" <<<"$INSTALLER_HELP" || die "Downloaded Wazuh installer does not advertise the hardware-check bypass option (-i)"
fi
if ((FORCE_REINSTALL == 1)); then
  grep -Fq -- "-o" <<<"$INSTALLER_HELP" || die "Downloaded Wazuh installer does not advertise overwrite mode (-o)"
fi

# Deliberately do NOT patch gpgcheck or the Wazuh signing key. The official
# assistant should configure its Wazuh RPM repository with package signature
# verification enabled.

# ---------- Run official all-in-one installation ----------
installer_args=(-a -v -id)

if ((DASHBOARD_PORT != 443)); then
  installer_args+=(-p "$DASHBOARD_PORT")
fi
if ((IGNORE_HARDWARE == 1)); then
  installer_args+=(-i)
fi
if ((FORCE_REINSTALL == 1)); then
  installer_args+=(-o)
fi

log "Launching official Wazuh all-in-one installer..."
(
  cd "$WORKDIR"
  bash "$INSTALLER" "${installer_args[@]}"
)

# Secure generated credential archive if present.
if [[ -f "$WORKDIR/wazuh-install-files.tar" ]]; then
  chmod 0600 "$WORKDIR/wazuh-install-files.tar"
fi

# ---------- Service validation ----------
services=(wazuh-indexer wazuh-manager filebeat wazuh-dashboard)
service_failure=0
log "Validating Wazuh services..."
for svc in "${services[@]}"; do
  if systemctl is-active --quiet "$svc"; then
    log "Service ${svc}: active"
  else
    warn "Service ${svc}: NOT ACTIVE"
    systemctl status "$svc" --no-pager -l || true
    journalctl -u "$svc" --no-pager -n 80 || true
    service_failure=1
  fi
done

if ((service_failure != 0)); then
  die "One or more Wazuh services are not active"
fi

# ---------- Wait until the indexer answers HTTPS ----------
log "Waiting for Wazuh Indexer HTTPS endpoint..."
indexer_http=""
for _ in $(seq 1 60); do
  indexer_http="$(curl -k -sS --max-time 5 -o /dev/null -w '%{http_code}' https://127.0.0.1:9200/ || true)"
  case "$indexer_http" in
    200|401|403)
      break
      ;;
  esac
  sleep 5
done

case "$indexer_http" in
  200|401|403)
    log "Wazuh Indexer is responding over HTTPS (HTTP ${indexer_http})."
    ;;
  *)
    journalctl -u wazuh-indexer --no-pager -n 120 || true
    die "Wazuh Indexer did not become ready; last HTTP status: ${indexer_http:-none}"
    ;;
esac

# ---------- Read generated admin credential without changing it ----------
ADMIN_PASSWORD=""
CREDENTIAL_TAR="$WORKDIR/wazuh-install-files.tar"
if [[ -f "$CREDENTIAL_TAR" ]]; then
  ADMIN_PASSWORD="$(python3 - "$CREDENTIAL_TAR" <<'PY'
import re
import sys
import tarfile

path = sys.argv[1]
try:
    with tarfile.open(path, "r:*") as tf:
        member = next((m for m in tf.getmembers() if m.name.endswith("wazuh-passwords.txt")), None)
        if member is None:
            raise SystemExit(0)
        f = tf.extractfile(member)
        if f is None:
            raise SystemExit(0)
        text = f.read().decode("utf-8", errors="replace")
except Exception:
    raise SystemExit(0)

user = None
for raw in text.splitlines():
    line = raw.strip()
    m = re.match(r"indexer_username:\s*['\"]?([^'\"\s]+)", line)
    if m:
        user = m.group(1)
        continue
    m = re.match(r"indexer_password:\s*['\"]?([^'\"\s]+)", line)
    if m and user == "admin":
        print(m.group(1))
        break
PY
)"
fi

# ---------- Authenticated indexer validation ----------
if [[ -n "$ADMIN_PASSWORD" ]]; then
  log "Testing generated admin credential against Wazuh Indexer..."
  if ! curl -kfsS --max-time 10 \
      --user "admin:${ADMIN_PASSWORD}" \
      https://127.0.0.1:9200/ >/dev/null; then
    die "Generated admin credential could not authenticate to Wazuh Indexer"
  fi
  log "Indexer admin authentication: OK"
else
  warn "Could not automatically read the generated admin password from wazuh-install-files.tar. The installation may still be healthy; inspect ${CREDENTIAL_TAR} or /var/log/wazuh-install.log."
fi

# ---------- Dashboard validation ----------
log "Testing Wazuh Dashboard HTTPS endpoint..."
if ! curl -kfsS --location --max-time 15 \
    "https://127.0.0.1:${DASHBOARD_PORT}/" >/dev/null; then
  journalctl -u wazuh-dashboard --no-pager -n 120 || true
  die "Wazuh Dashboard HTTPS health check failed on port ${DASHBOARD_PORT}"
fi
log "Dashboard HTTPS check: OK"

SERVER_IP="$(ip -4 -o addr show scope global 2>/dev/null | awk 'NR==1 {split($4,a,"/"); print a[1]}')"
if [[ -z "$SERVER_IP" ]]; then
  SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
fi
SERVER_IP="${SERVER_IP:-127.0.0.1}"

# ---------- Final summary ----------
printf '\n============================================================\n'
printf ' WAZUH ALL-IN-ONE INSTALLATION COMPLETED\n'
printf '============================================================\n'
printf ' Dashboard : https://%s:%s\n' "$SERVER_IP" "$DASHBOARD_PORT"
printf ' Username  : admin\n'
if [[ -n "$ADMIN_PASSWORD" ]]; then
  printf ' Password  : %s\n' "$ADMIN_PASSWORD"
else
  printf ' Password  : See %s\n' "$CREDENTIAL_TAR"
fi
printf ' Installer : %s\n' "$INSTALLER"
printf ' Log       : %s\n' "$LOGFILE"
printf ' Wazuh log : /var/log/wazuh-install.log\n'
printf '============================================================\n'

if ((NO_FIREWALL == 0)); then
  printf '\nRequired inbound ports for normal agent/dashboard use:\n'
  printf '  TCP/%s  Dashboard HTTPS\n' "$DASHBOARD_PORT"
  printf '  TCP/1514 Agent events\n'
  printf '  TCP/1515 Agent enrollment\n'
  if ((OPEN_API == 1)); then
    printf '  TCP/55000 Wazuh API (--open-api requested)\n'
  else
    printf '  TCP/55000 Wazuh API (NOT opened by this script by default)\n'
  fi
fi

log "Installation and post-install validation completed successfully."
