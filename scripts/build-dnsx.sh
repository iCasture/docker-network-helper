#!/bin/sh
set -eu

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 OUTPUT_DIR PLATFORM..." >&2
    exit 1
fi

output_dir=$1
shift

# Keep the module cache while isolating the binaries written by go install.
GOMODCACHE=$(go env GOMODCACHE)
host_platform=$(go env GOHOSTOS)/$(go env GOHOSTARCH)
GOPATH=$(mktemp -d)
trap 'rm -rf "$GOPATH"' EXIT
unset GOBIN
# Allow newer toolchains when dnsx raises its minimum Go version.
export GOMODCACHE GOPATH CGO_ENABLED=0 GOOS=linux GOTOOLCHAIN=auto

for platform do
    case "$platform" in
        linux/amd64|linux/386|linux/riscv64) arch=${platform#linux/} ;;
        linux/arm64|linux/arm64/v8) arch=arm64 ;;
        linux/arm/v7) arch=arm ;;
        *) echo "Unsupported dnsx platform: $platform" >&2; exit 1 ;;
    esac

    echo "Building dnsx ${DNSX_VERSION:-latest} for $platform"
    GOARCH="$arch" GOARM=7 go install -trimpath -ldflags='-s -w' \
        "github.com/projectdiscovery/dnsx/cmd/dnsx@${DNSX_VERSION:-latest}"

    install_dir=$GOPATH/bin
    if [ "linux/$arch" != "$host_platform" ]; then
        install_dir=$install_dir/linux_$arch
    fi
    mkdir -p "$output_dir/$arch"
    binary=$output_dir/$arch/dnsx
    install -m 0755 "$install_dir/dnsx" "$binary"
    go version "$binary"
done
