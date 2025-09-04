#!/bin/bash

# Script to setup mitmproxy based on architecture support
# For supported architectures: installs mitmproxy
# For unsupported architectures: creates placeholder scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main function
main() {
    print_info "Setting up mitmproxy ..." >&2

    # Check if architecture is supported
    if "$SCRIPT_DIR/check-mitmproxy-platform-and-arch.sh"; then
        print_info "Platform and distro support mitmproxy - proceeding with installation" >&2

        # Run the mitmproxy installation script
        if "$SCRIPT_DIR/install-mitmproxy.sh"; then
            print_info "mitmproxy installation completed successfully" >&2
        else
            print_error "mitmproxy installation failed"
            exit 1
        fi
    else
        print_warning "Platform or distro does not support mitmproxy, creating placeholder scripts to provide informative error messages" >&2

        # Create placeholder scripts
        if "$SCRIPT_DIR/create-mitmproxy-placeholders.sh"; then
            print_info "mitmproxy placeholders created successfully" >&2
        else
            print_error "Failed to create mitmproxy placeholders"
            exit 1
        fi
    fi

    print_info "mitmproxy setup completed." >&2
}

# Run main function
main "$@"
