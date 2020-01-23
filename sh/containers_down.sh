#!/bin/bash -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - - -
containers_down()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    down \
    --remove-orphans
}

# - - - - - - - - - - - - - - - - - - - - - - -
containers_down
