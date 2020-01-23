#!/bin/bash -Eeu

readonly SH_DIR="$( cd "$( dirname "${0}" )/sh" && pwd )"

source "${SH_DIR}/versioner_env_vars.sh"
export $(versioner_env_vars)
"${SH_DIR}/build_docker_images.sh"
#"${SH_DIR}/containers_up.sh"
#echo TODO: now run hiker-like check_red_amber_green.sh does...
#"${SH_DIR}/containers_down.sh"
"${SH_DIR}/on_ci_publish_image.sh"
