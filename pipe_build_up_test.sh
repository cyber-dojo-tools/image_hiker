#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

source "${SH_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)
"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/containers_up.sh"
echo TODO: now run hiker like check_red_amber_green.sh does...
echo TODO: bring down containers
