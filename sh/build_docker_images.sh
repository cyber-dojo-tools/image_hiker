#!/bin/bash -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - -
build_docker_images()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    hiker
}

# - - - - - - - - - - - - - - - - - - - - - - -
build_docker_images
