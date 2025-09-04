#!/bin/bash

# Script to create placeholder mitmproxy binaries for unsupported platforms/OS
# These placeholders provide informative error messages when executed
# Environment: TARGETPLATFORM can be set to override platform detection
# Note: mitmproxy is only supported on Debian/Ubuntu systems with amd64/arm64v8 platforms

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to create placeholder binaries
main() {
    local target_dir
    target_dir="${1:-/usr/local/bin}"

    if [ -z "${target_dir}" ]; then
        print_error "Target directory is required"
        exit 1
    fi

    print_info "Creating mitmproxy placeholder scripts ..." >&2
    print_info "Target directory: ${target_dir}" >&2

    # Ensure target directory exists
    mkdir -p "${target_dir}"

    # List of mitmproxy binaries to create placeholders for
    local binaries=("mitmproxy" "mitmdump" "mitmweb")

    for binary in "${binaries[@]}"; do
        local target_file="${target_dir}/${binary}"

        print_info "Creating placeholder for: ${binary}" >&2

        # Create the placeholder script
        cat > "${target_file}" << 'PLACEHOLDER_EOF'
#!/bin/sh

echo "Error: $0 is not supported on this system." >&2
echo >&2
echo "mitmproxy official prebuilt binaries is only available on glibc-based distributions with linux/amd64 or linux/arm64 architectures." >&2
echo "Please use a supported system to access mitmproxy functionality, or install mitmproxy via pip." >&2

exit 1
PLACEHOLDER_EOF

        # Make it executable
        chmod +x "${target_file}"

        print_info "Created placeholder: ${target_file}" >&2
    done

    print_info "All mitmproxy placeholders created successfully" >&2
}

# Run main function with all arguments
main "$@"
