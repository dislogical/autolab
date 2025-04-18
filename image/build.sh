#!/bin/bash

IMAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo "$IMAGE_DIR"/pi-gen/build.sh -f "$IMAGE_DIR"/config
