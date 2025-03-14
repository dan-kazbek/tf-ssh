#!/usr/bin/env bash

THIS_DIR=$( cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P )

set -eo pipefail

error() {
    echo >&2 "* Error: $*"
}

fatal() {
    error "$@"
    exit 1
}

message() {
    echo "$@"
}


source "$THIS_DIR/docker-config.sh" || \
    fatal "Could not load configuration from $THIS_DIR/docker-config.sh"

# source docker-private-config.sh
# the private configuration file must contain the following variables:
# GH_USER - Github username
# CR_PAT - Github personal access token (classic) with the permission to write pacakges
# PUSH_IMAGE_NAME - the image name to push to the registry
# PUSH_IMAGE_NAME should be the full URL with a tag, i.e. ghcr.io/username/image:tag
if [[ -e "$THIS_DIR/docker-private-config.sh" ]]; then
    # shellcheck source=docker-private-config.sh
    source "$THIS_DIR/docker-private-config.sh" || \
        fatal "Could not load configuration from $THIS_DIR/docker-private-config.sh"
fi

[[ -z "$PUSH_IMAGE_NAME" ]] && fatal "PUSH_IMAGE_NAME variable is not set";
[[ -z "$CR_PAT" ]] && fatal "CR_PAT variable is not set"
[[ -z "$GH_USER" ]] && fatal "GH_USER variable is not set"

echo "Image Configuration:"
echo "IMAGE_NAME:        $IMAGE_NAME"
echo "IMAGE:             $IMAGE"
echo "PUSH_IMAGE_NAME:   $PUSH_IMAGE_NAME"

# Login to the Github package registry
echo "$CR_PAT" | docker login ghcr.io -u "$GH_USER" --password-stdin

set -xe
docker tag "$IMAGE" "$PUSH_IMAGE_NAME"

# Push image
docker push "$PUSH_IMAGE_NAME"
