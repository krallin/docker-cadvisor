#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

# Entrypoint smoke test. Just checks that the entrypoint is executable
# and runs cadvisor by default
docker run -it --rm "$IMG" ls /usr/local/bin
docker run -it --rm "$IMG" 2>&1 | grep -q "CADVISOR_USER"

echo "Test OK!"
