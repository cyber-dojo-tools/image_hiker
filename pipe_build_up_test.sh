#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

versioner_env_vars()
{
  docker run --rm cyberdojo/versioner:latest sh -c 'cat /app/.env'
}

export $(versioner_env_vars)
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/containers_up.sh"
