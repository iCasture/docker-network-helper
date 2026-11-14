#!/bin/bash

# Emit comma-separated Docker Hub and GHCR image references for Docker Bake.
# Usage: generate-image-tags.sh <versioned-distro-tag> <distro-tag> <targets> <short-sha> <owner-lowercase> <dockerhub-username>

set -euo pipefail

# Input parameters
VERSIONED_DISTRO_TAG="$1"
DISTRO_TAG="$2"
TARGETS="$3"
SHORT_SHA="$4"
OWNER_LOWERCASE="$5"
DOCKERHUB_USERNAME="$6"

# Initialize variables
DOCKERHUB_URL="docker.io/${DOCKERHUB_USERNAME}/network-helper"
GHCR_URL="ghcr.io/${OWNER_LOWERCASE}/network-helper"
SHA_PREFIX="git-${SHORT_SHA}"

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
    tags="${tags},${DOCKERHUB_URL}:${DISTRO_TAG}-basic"
    tags="${tags},${DOCKERHUB_URL}:${VERSIONED_DISTRO_TAG}-basic"
    tags="${tags},${DOCKERHUB_URL}:latest-${DISTRO_TAG}-basic"
    tags="${tags},${DOCKERHUB_URL}:latest-${VERSIONED_DISTRO_TAG}-basic"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${DISTRO_TAG}-basic"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:${DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:${VERSIONED_DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:latest-${DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:latest-${VERSIONED_DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${DISTRO_TAG}-basic"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-basic"

  elif [ "$target" = "standard" ]; then
    # Standard image tags without suffix (default tags)
    tags="${tags},${DOCKERHUB_URL}:${DISTRO_TAG}"
    tags="${tags},${DOCKERHUB_URL}:${VERSIONED_DISTRO_TAG}"
    tags="${tags},${DOCKERHUB_URL}:latest-${DISTRO_TAG}"
    tags="${tags},${DOCKERHUB_URL}:latest-${VERSIONED_DISTRO_TAG}"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${DISTRO_TAG}"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:${DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:${VERSIONED_DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:latest-${DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:latest-${VERSIONED_DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${DISTRO_TAG}"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}"

    # Standard image tags with -standard suffix
    tags="${tags},${DOCKERHUB_URL}:${DISTRO_TAG}-standard"
    tags="${tags},${DOCKERHUB_URL}:${VERSIONED_DISTRO_TAG}-standard"
    tags="${tags},${DOCKERHUB_URL}:latest-${DISTRO_TAG}-standard"
    tags="${tags},${DOCKERHUB_URL}:latest-${VERSIONED_DISTRO_TAG}-standard"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${DISTRO_TAG}-standard"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:${DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:${VERSIONED_DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:latest-${DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:latest-${VERSIONED_DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${DISTRO_TAG}-standard"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-standard"

    # Add latest tag for ubuntu-based standard images
    if [ "${DISTRO_TAG}" = "ubuntu" ]; then
      tags="${tags},${DOCKERHUB_URL}:latest"
      tags="${tags},${GHCR_URL}:latest"
    fi

  elif [ "$target" = "advanced" ]; then
    # Advanced image tags with -advanced suffix
    tags="${tags},${DOCKERHUB_URL}:${DISTRO_TAG}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${VERSIONED_DISTRO_TAG}-advanced"
    tags="${tags},${DOCKERHUB_URL}:latest-${DISTRO_TAG}-advanced"
    tags="${tags},${DOCKERHUB_URL}:latest-${VERSIONED_DISTRO_TAG}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${DISTRO_TAG}-advanced"
    tags="${tags},${DOCKERHUB_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:${DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:${VERSIONED_DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:latest-${DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:latest-${VERSIONED_DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${DISTRO_TAG}-advanced"
    tags="${tags},${GHCR_URL}:${SHA_PREFIX}-${VERSIONED_DISTRO_TAG}-advanced"
  fi

  # Remove leading comma and assign to variable
  tags="${tags#,}"
  printf -v "$tags_var" '%s' "$tags"
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

# Validate the complete tags after adding Git SHA, latest, and target affixes.
LC_ALL=C
docker_tag_pattern='^[A-Za-z0-9_][A-Za-z0-9_.-]{0,127}$'
IFS=',' read -ra image_references <<< "$ALL_TAGS"
for image_reference in "${image_references[@]}"; do
  repository_and_tag="${image_reference##*/}"
  published_tag="${repository_and_tag#*:}"
  if [[ ! $published_tag =~ $docker_tag_pattern ]]; then
    printf 'Invalid Docker image tag in %s (tags must be 1 to 128 characters and use Docker tag syntax)\n' "$image_reference" >&2
    exit 1
  fi
done

# Output all tags as comma-separated list
echo "tags=${ALL_TAGS}"

# Output individual target tags as comma-separated lists
echo "tags-basic=${TAGS_BASIC}"
echo "tags-standard=${TAGS_STANDARD}"
echo "tags-advanced=${TAGS_ADVANCED}"
