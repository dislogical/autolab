#!/bin/bash

IMAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$IMAGE_DIR"/pi-gen/build-docker.sh -c "$IMAGE_DIR"/config
