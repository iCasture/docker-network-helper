#!/bin/bash

# Script to check if current arch and distro supports mitmproxy
# Returns: 0 if supported, 1 if not supported
# Usage: check-mitmproxy-platform.sh [--silent]
# Environment: TARGETPLATFORM can be set to override platform detection

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if silent mode is requested
SILENT=false
if [[ "${1:-}" == "--silent" ]]; then
    SILENT=true
fi

# Function to print colored output (respects silent mode)
print_info() {
    if [[ "$SILENT" == false ]]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

print_error() {
    if [[ "$SILENT" == false ]]; then
        echo -e "${RED}[ERROR]${NC} $1" >&2
    fi
}

# Function to detect platform
detect_platform() {
    # Use TARGETPLATFORM if available (Docker buildx)
    if [[ -n "${TARGETPLATFORM:-}" ]]; then
        echo "$TARGETPLATFORM"
        return
    fi

    # Fallback to uname -m
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "linux/amd64"
            ;;
        aarch64|arm64)
            echo "linux/arm64"
            ;;
        armv7l)
            echo "linux/arm/v7"
            ;;
        i386|i686)
            echo "linux/386"
            ;;
        riscv64)
            echo "linux/riscv64"
            ;;
        *)
            echo "linux/unknown"
            ;;
    esac
}

# Function to detect distro
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # Read distro information from /etc/os-release
        local distro
        distro=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
        echo "$distro"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Function to check if distro is Debian-based
is_debian_based() {
    local distro
    distro=$(detect_distro)

    case "$distro" in
        debian|ubuntu)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check arch and distro support
check_support() {
    local platform
    local distro

    platform=$(detect_platform)
    distro=$(detect_distro)

    print_info "Detected platform: '${platform}'" >&2
    print_info "Detected distro: '${distro}'" >&2

    # Check platform first
    case "$platform" in
        linux/amd64|linux/arm64|linux/arm64/v8)
            print_info "Platform '${platform}': supported for mitmproxy official prebuilt binaries" >&2
            ;;
        *)
            print_error "Platform '${platform}': not supported for mitmproxy official prebuilt binaries"
            print_error "mitmproxy official prebuilt binaries requires linux/amd64 or linux/arm64 platforms"
            return 1
            ;;
    esac

    # Check distro
    if is_debian_based; then
        print_info "Distro '${distro}': supported for mitmproxy (Debian-based)" >&2
        print_info "Platform '${platform}' + Distro '${distro}': mitmproxy is fully supported" >&2
        return 0
    else
        print_error "Distro '${distro}': not supported for mitmproxy official prebuilt binaries"
        print_error "mitmproxy official prebuilt binaries requires glibc-based distributions"
        print_error "Our images only support Alpine, Debian, and Ubuntu, which effectively means only Debian / Ubuntu can use the prebuilt binaries."
        print_error "For other platforms, please install mitmproxy via pip."
        return 1
    fi
}

# Main execution
if check_support; then
    exit 0
else
    exit 1
fi
