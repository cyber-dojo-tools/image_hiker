#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

containers_down()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    down \
    --remove-orphans
}

containers_down
