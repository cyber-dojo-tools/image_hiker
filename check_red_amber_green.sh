#!/bin/bash -Ee

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly LTF_IMAGE_NAME=${1}
readonly SRC_DIR=${2:-${PWD}}

# - - - - - - - - - - - - - - - - - - - - -
# $ cd ~/repo/cyber-dojo-languages/java-junit
# $ ../../cyber-dojo/commander/cyber-dojo start-point create jj1 --languages ${PWD}
# this creates start-point called jj1
# $ cd ../image_hiker
# $ ./check_red_amber_green.sh jj1 ../java-junit
# Creating network hiker
# Creating hiker-languages service
# Creating hiker-runner service
# Creating hiker-ragger service
# Waiting until hiker-ragger is ready.....OK
# Waiting until hiker-runner is ready.OK
# Waiting until hiker-languages is ready.OK
# red
# amber
# green
# - - - - - - - - - - - - - - - - - - - - -


# - - - - - - - - - - - - - - - - - - - - -
ip_address()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}

readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - - -
readonly READY_FILENAME='/tmp/curl-ready-output'

wait_until_ready()
{
  local -r name="hiker-${1}"
  local -r port="${2}"
  local -r max_tries=20
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    if ready ${port} ; then
      printf '.OK\n'
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

# - - - - - - - - - - - - - - - - - - -
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

# - - - - - - - - - - - - - - - - - - -
trap_handler()
{
  remove_languages_service
  remove_runner_service
  remove_ragger_service
  remove_docker_network
}

trap trap_handler EXIT

src_dir_abs()
{
  # docker volume-mounts cannot be relative
  echo $(cd ${SRC_DIR} && pwd)
}

image_name()
{
  docker run \
    --rm \
    --volume "$(src_dir_abs):/data:ro" \
    cyberdojofoundation/image_namer
}

# - - - - - - - - - - - - - - - - - - - - - - -
network_name()
{
  echo traffic-light
}

create_docker_network()
{
  echo "Creating network $(network_name)"
  local -r msg=$(docker network create $(network_name))
}

remove_docker_network()
{
  docker network remove $(network_name) > /dev/null
}

# - - - - - - - - - - - - - - - - - - - - - - -
languages_service_name()
{
  echo hiker-languages
}

remove_languages_service()
{
  docker rm --force $(languages_service_name) > /dev/null || true
}

start_languages_service()
{
  local -r port="${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}"
  echo "Creating $(languages_service_name) service"
  local -r cid=$(docker run \
    --detach \
    --env NO_PROMETHEUS \
    --init \
    --name $(languages_service_name) \
    --network $(network_name) \
    --network-alias languages \
    --publish "${port}:${port}" \
    --read-only \
    --restart no \
    --tmpfs /tmp \
    --user nobody \
      ${LTF_IMAGE_NAME})
}

# - - - - - - - - - - - - - - - - - - - - - - -
runner_service_name()
{
  echo hiker-runner
}

remove_runner_service()
{
  docker rm --force $(runner_service_name) > /dev/null || true
}

start_runner_service()
{
  local -r image="${CYBER_DOJO_RUNNER_IMAGE}:${CYBER_DOJO_RUNNER_TAG}"
  local -r port="${CYBER_DOJO_RUNNER_PORT}"
  echo "Creating $(runner_service_name) service"
  local -r cid=$(docker run \
     --detach \
     --env NO_PROMETHEUS \
     --init \
     --name $(runner_service_name) \
     --network $(network_name) \
     --network-alias runner \
     --publish "${port}:${port}" \
     --read-only \
     --restart no \
     --tmpfs /tmp \
     --user root \
     --volume /var/run/docker.sock:/var/run/docker.sock \
       "${image}")
}

# - - - - - - - - - - - - - - - - - - - - - - -
ragger_service_name()
{
  echo hiker-ragger
}

remove_ragger_service()
{
  docker rm --force $(ragger_service_name) > /dev/null || true
}

start_ragger_service()
{
  local -r image="${CYBER_DOJO_RAGGER_IMAGE}:${CYBER_DOJO_RAGGER_TAG}"
  local -r port="${CYBER_DOJO_RAGGER_PORT}"
  echo "Creating $(ragger_service_name) service"
  local -r cid=$(docker run \
    --detach \
    --env NO_PROMETHEUS \
    --init \
    --name $(ragger_service_name) \
    --network $(network_name) \
    --network-alias ragger \
    --publish "${port}:${port}" \
    --read-only \
    --restart no \
    --tmpfs /tmp \
    --user nobody \
      "${image}")
}

# - - - - - - - - - - - - - - - - - - - - - - -
hiker_service_name()
{
  echo hiker
}

run_hiker_service()
{
  local -r colour="${1}" # eg red
  docker run \
    --env NO_PROMETHEUS \
    --env SRC_DIR=$(src_dir_abs) \
    --init \
    --name $(hiker_service_name) \
    --network $(network_name) \
    --read-only \
    --restart no \
    --rm \
    --tmpfs /tmp \
    --user nobody \
    --volume $(src_dir_abs):$(src_dir_abs):ro \
      cyberdojofoundation/image_hiker:latest "${colour}"
}

# - - - - - - - - - - - - - - - - - - - - - - -
source "${ROOT_DIR}/sh/versioner_env_vars.sh"
export $(versioner_env_vars)
create_docker_network
start_languages_service
start_runner_service
start_ragger_service

wait_until_ready ragger    "${CYBER_DOJO_RAGGER_PORT}"
wait_until_ready runner    "${CYBER_DOJO_RUNNER_PORT}"
wait_until_ready languages "${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}"

run_hiker_service red
run_hiker_service amber
run_hiker_service green

# if something goes wrong we need to look at ragger's log
# docker logs $(ragger_service_name). Better to pass red|amber|green
# to hiker.
