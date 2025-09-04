#!/bin/bash

# Script to generate Docker image tags for multiple build targets
# Usage: set-multi-image-tags.sh <variant> <base-type> <targets> <sha> <owner-lowercase> <dockerhub-username>

set -euo pipefail

# Input parameters
VARIANT="$1"
BASE_TYPE="$2"
TARGETS="$3"
SHA="$4"
OWNER_LOWERCASE="$5"
DOCKERHUB_USERNAME="$6"

# Initialize variables
DOCKERHUB_URL="docker.io/${DOCKERHUB_USERNAME}/network-helper"
GHCR_URL="ghcr.io/${OWNER_LOWERCASE}/network-helper"
SHA_PREFIX="git-${SHA}"

# Set base variant names using passed base-type
BASE_VARIANT="${BASE_TYPE}"
BASE_VARIANT_FULL="${VARIANT}"

# Parse targets and trim whitespace
IFS=',' read -ra TARGETS_RAW <<< "${TARGETS}"
TARGETS_ARRAY=()
for target in "${TARGETS_RAW[@]}"; do
  # Trim leading and trailing whitespace
  target=$(echo "$target" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  TARGETS_ARRAY+=("$target")
done

# Initialize tag arrays for each target
TAGS_BASIC=""
TAGS_STANDARD=""
TAGS_ADVANCED=""
ALL_TAGS=""

# Function to generate tags for a specific target
generate_tags() {
  local target
  local tags_var
  local tags
  target="$1"
  tags_var="TAGS_$(echo "$target" | tr '[:lower:]' '[:upper:]')"
  tags=""

  if [ "$target" = "basic" ]; then
    # Basic image tags with -basic suffix
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT}-basic"
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT_FULL}-basic"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT}-basic"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT_FULL}-basic"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT}-basic"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-basic"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT}-basic"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT_FULL}-basic"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT}-basic"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT_FULL}-basic"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT}-basic"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-basic"

  elif [ "$target" = "standard" ]; then
    # Standard image tags without suffix (default tags)
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT}"
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT_FULL}"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT}"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT_FULL}"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT}"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT}"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT_FULL}"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT}"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT_FULL}"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT}"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}"

    # Standard image tags with -standard suffix
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT}-standard"
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT_FULL}-standard"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT}-standard"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT_FULL}-standard"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT}-standard"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-standard"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT}-standard"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT_FULL}-standard"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT}-standard"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT_FULL}-standard"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT}-standard"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-standard"

    # Add latest tag for ubuntu-based standard images
    if [ "${BASE_VARIANT}" = "ubuntu" ]; then
      tags="${tags},${DOCKERHUB_URL}:latest"
      tags="${tags},${GHCR_URL}:latest"
    fi

  elif [ "$target" = "advanced" ]; then
    # Advanced image tags with -advanced suffix
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${BASE_VARIANT_FULL}-advanced"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT}-advanced"
    tags="${tags},${DOCKERHUB_URL}:latest-${BASE_VARIANT_FULL}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-advanced"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT}-advanced"
    tags="${tags},${GHCR_URL}:${BASE_VARIANT_FULL}-advanced"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT}-advanced"
    tags="${tags},${GHCR_URL}:latest-${BASE_VARIANT_FULL}-advanced"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT}-advanced"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${BASE_VARIANT_FULL}-advanced"
  fi

  # Remove leading comma and assign to variable
  tags="${tags#,}"
  eval "${tags_var}=\"${tags}\""
}

# Generate tags for each target
for target in "${TARGETS_ARRAY[@]}"; do
  generate_tags "$target"
done

# Combine all tags
ALL_TAGS="${TAGS_BASIC}"
if [ -n "${TAGS_STANDARD}" ]; then
  if [ -n "${ALL_TAGS}" ]; then
    ALL_TAGS="${ALL_TAGS},${TAGS_STANDARD}"
  else
    ALL_TAGS="${TAGS_STANDARD}"
  fi
fi
if [ -n "${TAGS_ADVANCED}" ]; then
  if [ -n "${ALL_TAGS}" ]; then
    ALL_TAGS="${ALL_TAGS},${TAGS_ADVANCED}"
  else
    ALL_TAGS="${TAGS_ADVANCED}"
  fi
fi

# Output all tags as comma-separated list
echo "tags=${ALL_TAGS}"

# Output individual target tags as comma-separated lists
echo "tags-basic=${TAGS_BASIC}"
echo "tags-standard=${TAGS_STANDARD}"
echo "tags-advanced=${TAGS_ADVANCED}"
