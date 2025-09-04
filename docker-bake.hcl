# Docker Bake configuration for multi-target builds
# This file defines the build targets for basic, standard, and advanced variants

# Variable declarations
variable "MAINTAINER" { default = "unknown" }
variable "DISTRO" { default = "unknown" }
variable "DISTRO_VERSION" { default = "unknown" }
variable "PLATFORMS" { default = "" }
variable "BUILD_DATE" { default = "unknown" }
variable "BUILD_EPOCH" { default = "unknown" }
variable "GIT_COMMIT" { default = "unknown" }
variable "MITMPROXY_VERSION" { default = "" }
variable "TAGS_BASIC" { default = "" }
variable "TAGS_STANDARD" { default = "" }
variable "TAGS_ADVANCED" { default = "" }

# Global configuration
group "default" {
  targets = ["basic", "standard", "advanced"]
}

target "basic" {
  context = "."
  dockerfile = "./Dockerfile.${DISTRO}"
  target = "basic"
  platforms = [for p in split(",", PLATFORMS) : trimspace(p)]
  tags = [for t in split(",", TAGS_BASIC) : trimspace(t)]
  args = {
    MAINTAINER = "${MAINTAINER}"
    DISTRO = "${DISTRO}"
    DISTRO_VERSION = "${DISTRO_VERSION}"
    PLATFORMS = "${PLATFORMS}"
    BUILD_DATE = "${BUILD_DATE}"
    BUILD_EPOCH = "${BUILD_EPOCH}"
    GIT_COMMIT = "${GIT_COMMIT}"
    MITMPROXY_VERSION = "${MITMPROXY_VERSION}"
  }
}

target "standard" {
  context = "."
  dockerfile = "./Dockerfile.${DISTRO}"
  target = "standard"
  platforms = [for p in split(",", PLATFORMS) : trimspace(p)]
  tags = [for t in split(",", TAGS_STANDARD) : trimspace(t)]
  args = {
    MAINTAINER = "${MAINTAINER}"
    DISTRO = "${DISTRO}"
    DISTRO_VERSION = "${DISTRO_VERSION}"
    PLATFORMS = "${PLATFORMS}"
    BUILD_DATE = "${BUILD_DATE}"
    BUILD_EPOCH = "${BUILD_EPOCH}"
    GIT_COMMIT = "${GIT_COMMIT}"
    MITMPROXY_VERSION = "${MITMPROXY_VERSION}"
  }
}

target "advanced" {
  context = "."
  dockerfile = "./Dockerfile.${DISTRO}"
  target = "advanced"
  platforms = [for p in split(",", PLATFORMS) : trimspace(p)]
  tags = [for t in split(",", TAGS_ADVANCED) : trimspace(t)]
  args = {
    MAINTAINER = "${MAINTAINER}"
    DISTRO = "${DISTRO}"
    DISTRO_VERSION = "${DISTRO_VERSION}"
    PLATFORMS = "${PLATFORMS}"
    BUILD_DATE = "${BUILD_DATE}"
    BUILD_EPOCH = "${BUILD_EPOCH}"
    GIT_COMMIT = "${GIT_COMMIT}"
    MITMPROXY_VERSION = "${MITMPROXY_VERSION}"
  }
}
