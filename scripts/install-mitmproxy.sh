#!/bin/bash

# Script to download and install the latest mitmproxy binaries
# Author: Auto-generated script
# Description: Downloads the latest mitmproxy release and installs the binaries
# Supported platforms: linux/amd64, linux/arm64/v8 on Debian/Ubuntu systems only

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global variable for temporary directory
TEMP_DIR=""

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running as root
is_root() {
    [ "$(id -u)" -eq 0 ]
}

# Check required commands
check_dependencies() {
    local missing_deps=()

    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if ! command_exists tar; then
        missing_deps+=("tar")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_error "Please install them and try again."
        exit 1
    fi
}

# Function to get the latest version from GitHub API
get_latest_version() {
    # Check if version is provided as environment variable
    if [ -n "${MITMPROXY_VERSION:-}" ]; then
        print_info "Using provided mitmproxy version: $MITMPROXY_VERSION" >&2
        echo "$MITMPROXY_VERSION"
        return
    fi

    print_info "Fetching latest mitmproxy version from GitHub API ..." >&2

    local response
    local max_retries=7
    local retry_delay=10
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        print_info "GitHub API attempt $attempt of $max_retries" >&2

        response=$(curl --connect-timeout 60 \
                        --max-time 180 \
                        --retry 0 \
                        --retry-delay 0 \
                        --retry-max-time 0 \
                        --fail-with-body \
                        --location \
                        -w "%{http_code}" \
                        -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15" \
                        -H "Accept: application/vnd.github.v3+json" \
                        "https://api.github.com/repos/mitmproxy/mitmproxy/releases/latest")

        local curl_exit_code=$?

        if [ $curl_exit_code -eq 0 ] && [ -n "$response" ]; then
            print_info "GitHub API call successful on attempt $attempt" >&2
            break
        else
            print_warning "GitHub API attempt $attempt failed with exit code $curl_exit_code" >&2

            if [ $attempt -eq $max_retries ]; then
                print_error "Failed to fetch version from GitHub API after $max_retries attempts"
                exit 1
            fi

            print_info "Waiting $retry_delay seconds before retry..." >&2
            sleep $retry_delay

            attempt=$((attempt + 1))
        fi
    done

    local http_code
    local body
    http_code="${response: -3}"
    body="${response::-3}"

    version=$(printf '%s' "$body" | tr -d '\000-\037' | jq -r '.tag_name | ltrimstr("v")')

    print_info "Fetched latest mitmproxy version: '$version'" >&2
    print_info "GitHub API HTTP status code: '$http_code'" >&2
    # print_info "GitHub API response body: '$body'" >&2

    if [ -z "$version" ]; then
        print_error "Failed to get version from GitHub API"
        exit 1
    fi

    print_info "Latest version found: $version" >&2
    echo "$version"

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

# Function to convert platform to mitmproxy architecture string
platform_to_mitmproxy_arch() {
    local platform="$1"

    case "${platform}" in
        linux/amd64)
            echo "linux-x86_64"
            ;;
        linux/arm64|linux/arm64/v8)
            echo "linux-aarch64"
            ;;
        *)
            # Should never reach here due to validation above
            print_error "Internal error: unsupported platform ${platform}"
            exit 1
            ;;
    esac
}

# Function to build download URL
build_download_url() {
    local version="$1"
    local platform
    local mitm_arch_string

    platform=$(detect_platform)
    mitm_arch_string=$(platform_to_mitmproxy_arch "${platform}")

    echo "https://downloads.mitmproxy.org/${version}/mitmproxy-${version}-${mitm_arch_string}.tar.gz"
}

# Function to download mitmproxy
download_mitmproxy() {
    local url="$1"
    local temp_dir="$2"
    local filename
    local filepath

    filename=$(basename "$url")
    filepath="${temp_dir}/${filename}"

    print_info "Downloading mitmproxy from: $url" >&2

    # Download with improved reliability settings
    local max_retries=7
    local retry_delay=10
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        print_info "Download attempt $attempt of $max_retries" >&2

        if curl --connect-timeout 60 \
                --max-time 300 \
                --retry 0 \
                --retry-delay 0 \
                --retry-max-time 0 \
                --continue-at - \
                --fail-with-body \
                --location \
                --compressed \
                -o "$filepath" \
                "$url"; then
            print_info "Download completed successfully on attempt $attempt" >&2
            break
        else
            local exit_code=$?
            print_warning "Download attempt $attempt failed with exit code $exit_code" >&2

            if [ $attempt -eq $max_retries ]; then
                print_error "Failed to download mitmproxy after $max_retries attempts"
                exit 1
            fi

            print_info "Waiting $retry_delay seconds before retry..." >&2
            sleep $retry_delay
            attempt=$((attempt + 1))
        fi
    done

    print_info "Download completed: $filepath" >&2
    echo "$filepath"
}

# Function to extract and install binaries
extract_and_install() {
    local archive_path="$1"
    local temp_dir="$2"
    local extract_dir="${temp_dir}/extracted"

    print_info "Extracting archive ..." >&2

    # Create extraction directory
    mkdir -p "$extract_dir"

    # Extract the archive
    if ! tar -xzf "$archive_path" -C "$extract_dir"; then
        print_error "Failed to extract archive"
        exit 1
    fi

    # Find the extracted directory (it should contain the binaries)
    local bin_dir
    bin_dir=$(find "$extract_dir" -name "mitmproxy" -type f -exec dirname {} \; | head -1)

    if [ -z "$bin_dir" ]; then
        print_error "Could not find mitmproxy binaries in extracted archive"
        exit 1
    fi

    print_info "Found binaries in: $bin_dir" >&2

    # Install the three main binaries
    local binaries=("mitmproxy" "mitmdump" "mitmweb")

    for binary in "${binaries[@]}"; do
        local source_file="${bin_dir}/${binary}"
        local target_file="/usr/local/bin/${binary}"

        if [ -f "$source_file" ]; then
            print_info "Installing $binary to $target_file" >&2

            # Copy the binary (use sudo only if not root)
            if is_root; then
                if ! cp "$source_file" "$target_file"; then
                    print_error "Failed to copy $binary to $target_file"
                    exit 1
                fi
            else
                if ! sudo cp "$source_file" "$target_file"; then
                    print_error "Failed to copy $binary to $target_file"
                    exit 1
                fi
            fi

            # Make it executable (use sudo only if not root)
            if is_root; then
                if ! chmod +x "$target_file"; then
                    print_error "Failed to make $binary executable"
                    exit 1
                fi
            else
                if ! sudo chmod +x "$target_file"; then
                    print_error "Failed to make $binary executable"
                    exit 1
                fi
            fi

            print_info "Successfully installed $binary" >&2
        else
            print_warning "Binary $binary not found in archive, skipping..." >&2
        fi
    done
}

# Function to cleanup temporary files
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        print_info "Cleaning up temporary files ..." >&2
        rm -rf "$TEMP_DIR"
        print_info "Cleanup completed" >&2
    fi
}

# Main function
main() {
    print_info "Starting mitmproxy installation..." >&2

    # Check dependencies
    check_dependencies

    # Get latest version
    local version
    version=$(get_latest_version)

    # Build download URL
    local download_url
    download_url=$(build_download_url "$version")

    # Create temporary directory
    if ! TEMP_DIR=$(mktemp -d); then
        print_error "Failed to create temporary directory"
        exit 1
    fi
    readonly TEMP_DIR

    print_info "Using temporary directory: $TEMP_DIR" >&2

    # Set up cleanup trap
    trap cleanup EXIT

    # Download mitmproxy
    local archive_path
    archive_path=$(download_mitmproxy "$download_url" "$TEMP_DIR")

    # Extract and install
    extract_and_install "$archive_path" "$TEMP_DIR"

    print_info "mitmproxy installation completed successfully!" >&2
    print_info "You can now use: mitmproxy, mitmdump, mitmweb" >&2
}

# Run main function
main "$@"
