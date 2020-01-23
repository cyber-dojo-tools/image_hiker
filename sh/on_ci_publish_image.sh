#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
source "${MY_DIR}/image_name.sh"

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing image'
    return
  fi
  echo 'on CI so publishing image'
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push "$(image_name)"
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  set +u
  [ -n "${CIRCLECI}" ]
  local -r result=$?
  set -u
  [ "${result}" == '0' ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images
