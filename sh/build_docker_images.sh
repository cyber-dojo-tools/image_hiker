#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

source "${ROOT_DIR}/sh/versioner_env_vars.sh"
export $(versioner_env_vars)

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  build \
  hiker
