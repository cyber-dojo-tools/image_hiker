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
  docker push "$(image_name)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ "${CI:-}" == 'true' ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images
