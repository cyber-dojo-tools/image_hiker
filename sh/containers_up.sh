#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"

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

wait_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=20
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    #if $(curl_cmd ${port} ready?) ; then
    if ready "${port}" ; then
      printf '.OK\n'
      exit_unless_clean "${name}" "${port}"
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
  local -r curl_cmd="curl --output ${READY_FILENAME} --silent --fail --data {} -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "${READY_FILENAME}"
  if ${curl_cmd} && [ "$(cat "${READY_FILENAME}")" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r docker_log="$(docker logs "${name}" 2>&1)"
  local -r up_line="Listening on 0.0.0.0:${port}, CTRL+C to stop"
  printf "Checking ${name} started cleanly..."
  if echo "${docker_log}" | grep --silent "${up_line}" ; then
    echo OK
    echo "${up_line}"
  else
    echo FAIL
    echo_docker_log "${name}" "${docker_log}"
    exit 42
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
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  --detach \
  hiker

wait_until_ready test-hiker-runner    ${CYBER_DOJO_RUNNER_PORT}
wait_until_ready test-hiker-ragger    ${CYBER_DOJO_RAGGER_PORT}
wait_until_ready test-hiker-languages ${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}

# TODO: this is obsolete...
# Need to run the check_red_amber_green.sh script instead
