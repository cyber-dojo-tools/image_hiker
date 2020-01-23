#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )/.." && pwd )"

# - - - - - - - - - - - - - - - - - - - - - -
ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - - - -
readonly READY_FILENAME='/tmp/curl-ready-output'

up_and_wait_until_ready()
{
  local -r service="${1}"                        # eg runner
  local -r port="${2}"                           # eg 4597
  local -r name="test-traffic-light-${service}"  # eg test-traffic-light-runner
  local -r max_tries=20

  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    up \
    --detach \
    "${service}"

  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    if ready "${port}" ; then
      printf '.OK\n'
      show_warnings "${name}" "${port}"
      return
    else
      printf .
      sleep 0.2
    fi
  done
  printf 'FAIL\n'
  echo "${name} not ready after ${max_tries} tries"
  if [ -f "${READY_FILENAME}" ]; then
    echo "$(cat "${READY_FILENAME}")"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - - - - -
ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r curl_cmd="curl \
    --data {} \
    --fail \
    --output ${READY_FILENAME} \
    --silent \
    -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "${READY_FILENAME}"
  if ${curl_cmd} && [ "$(cat "${READY_FILENAME}")" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
show_warnings()
{
  local -r name="${1}" # eg test-traffic-light-runner
  local -r port="${2}" # eg 4597
  local -r docker_log="$(docker logs "${name}" 2>&1)"
  local stripped=${docker_log}
  stripped="$(echo "${stripped}" | grep --invert-match "Thin web server (v1.7.2 codename Bachmanity)")"
  stripped="$(echo "${stripped}" | grep --invert-match "Maximum connections set to 1024")"
  stripped="$(echo "${stripped}" | grep --invert-match "Listening on 0.0.0.0:${port}, CTRL+C to stop")"
  local -r count="$(echo "${stripped}" | grep --count "^")"
  if [ "${count}" != '0' ]; then
    echo "${count} warnings...."
    #echo "${stripped}"
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  echo "[docker logs ${name}]"
  echo "<docker_log>"
  echo "${docker_log}"
  echo "</docker_log>"
}

# - - - - - - - - - - - - - - - - - - - - - -
up_and_wait_until_ready runner ${CYBER_DOJO_RUNNER_PORT}
