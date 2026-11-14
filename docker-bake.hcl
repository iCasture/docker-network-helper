# Docker Bake configuration for multi-target builds
# This file defines the build targets for basic, standard, and advanced variants

# Variable declarations
variable "MAINTAINER" { default = "unknown" }
variable "DISTRO" { default = "unknown" }
variable "DISTRO_VERSION" { default = "unknown" }
variable "BASE_IMAGE_TAG" { default = "" }
variable "PLATFORMS" { default = "" }
variable "BUILD_DATE" { default = "unknown" }
variable "BUILD_EPOCH" { default = "unknown" }
variable "GIT_COMMIT" { default = "unknown" }
variable "MITMPROXY_VERSION" { default = "" }
variable "GO_BUILDER_IMAGE" { default = "" }
variable "TAGS_BASIC" { default = "" }
variable "TAGS_STANDARD" { default = "" }
variable "TAGS_ADVANCED" { default = "" }

# Global configuration
group "default" {
  targets = ["basic", "standard", "advanced"]
}

target "_common" {
  context = "."
  dockerfile = "./Dockerfile.${DISTRO}"
  platforms = [for p in split(",", PLATFORMS) : trimspace(p)]
  args = {
    MAINTAINER = "${MAINTAINER}"
    DISTRO = "${DISTRO}"
    DISTRO_VERSION = "${DISTRO_VERSION}"
    BASE_IMAGE_TAG = BASE_IMAGE_TAG != "" ? BASE_IMAGE_TAG : null
    PLATFORMS = "${PLATFORMS}"
    BUILD_DATE = "${BUILD_DATE}"
    BUILD_EPOCH = "${BUILD_EPOCH}"
    GIT_COMMIT = "${GIT_COMMIT}"
    MITMPROXY_VERSION = "${MITMPROXY_VERSION}"
  }
}

target "basic" {
  inherits = ["_common"]
  target = "basic"
  tags = [for t in split(",", TAGS_BASIC) : trimspace(t)]
}

target "standard" {
  inherits = ["_common"]
  target = "standard"
  tags = [for t in split(",", TAGS_STANDARD) : trimspace(t)]
}

target "advanced" {
  inherits = ["_common"]
  target = "advanced"
  args = {
    GO_BUILDER_IMAGE = GO_BUILDER_IMAGE != "" ? GO_BUILDER_IMAGE : null
  }
  tags = [for t in split(",", TAGS_ADVANCED) : trimspace(t)]
}
