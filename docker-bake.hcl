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
variable "REFRESH_IMAGES" { default = false }
variable "IMPORT_IMAGE_CACHE" { default = false }
variable "EXPORT_IMAGE_CACHE" { default = false }
variable "TAGS_BASIC" { default = "" }
variable "TAGS_STANDARD" { default = "" }
variable "TAGS_ADVANCED" { default = "" }

function "image_cache" {
  params = [variant]
  result = {
    type = "gha"
    scope = "network-helper-${DISTRO}-${variant}"
  }
}

# Global configuration
group "default" {
  targets = ["basic", "standard", "advanced"]
}

target "_common" {
  context = "."
  dockerfile = "./Dockerfile.${DISTRO}"
  platforms = [for p in split(",", PLATFORMS) : trimspace(p)]
  pull = REFRESH_IMAGES
  no-cache = REFRESH_IMAGES
  labels = {
    "build.date" = BUILD_DATE
    "build.epoch" = BUILD_EPOCH
    "build.git_commit" = GIT_COMMIT
  }
  args = {
    MAINTAINER = MAINTAINER
    DISTRO = DISTRO
    DISTRO_VERSION = DISTRO_VERSION
    BASE_IMAGE_TAG = BASE_IMAGE_TAG != "" ? BASE_IMAGE_TAG : null
    PLATFORMS = PLATFORMS
    MITMPROXY_VERSION = MITMPROXY_VERSION
  }
}

target "basic" {
  inherits = ["_common"]
  target = "basic"
  cache-from = IMPORT_IMAGE_CACHE ? [image_cache("basic")] : []
  cache-to = EXPORT_IMAGE_CACHE ? [merge(image_cache("basic"), { mode = "min" })] : []
  tags = [for t in split(",", TAGS_BASIC) : trimspace(t)]
}

target "standard" {
  inherits = ["_common"]
  target = "standard"
  cache-from = IMPORT_IMAGE_CACHE ? [image_cache("standard")] : []
  cache-to = EXPORT_IMAGE_CACHE ? [merge(image_cache("standard"), { mode = "min" })] : []
  tags = [for t in split(",", TAGS_STANDARD) : trimspace(t)]
}

target "advanced" {
  inherits = ["_common"]
  target = "advanced"
  cache-from = IMPORT_IMAGE_CACHE ? [image_cache("advanced")] : []
  cache-to = EXPORT_IMAGE_CACHE ? [merge(image_cache("advanced"), { mode = "max" })] : []
  args = {
    GO_BUILDER_IMAGE = GO_BUILDER_IMAGE != "" ? GO_BUILDER_IMAGE : null
  }
  tags = [for t in split(",", TAGS_ADVANCED) : trimspace(t)]
}
