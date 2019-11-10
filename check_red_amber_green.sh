#!/bin/bash
set -e

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly LTF_IMAGE_NAME=${1}
readonly SRC_DIR=${2:-${PWD}}

trap_handler()
{
  remove_languages_service
  remove_runner_service
  remove_ragger_service
  remove_hiker_service
  remove_docker_network
}

trap trap_handler INT EXIT

version_tags()
{
  local -r tag=${CYBER_DOJO_VERSION_TAG:-latest}
  docker run \
    --rm \
    --entrypoint cat \
    cyberdojo/versioner:${tag} \
      '/app/.env'
}

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
  echo hiker-network
}

create_docker_network()
{
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
  local -r cid=$(docker run \
    --user nobody \
    --detach \
    --init \
    --network $(network_name) \
    --network-alias languages \
    --name $(languages_service_name) \
    -p 4524:4524 \
    --env NO_PROMETHEUS \
    --read-only \
    --tmpfs /tmp \
    --restart no \
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
  local -r cid=$(docker run \
     --user root \
     --detach \
     --init \
     --network $(network_name) \
     --network-alias runner \
     --name $(runner_service_name) \
     -p 4597:4597 \
     --env NO_PROMETHEUS \
     --read-only \
     --tmpfs /tmp \
     --restart no \
     --volume /var/run/docker.sock:/var/run/docker.sock \
       cyberdojo/runner:${CYBER_DOJO_RUNNER_TAG})
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
  local -r cid=$(docker run \
    --user nobody \
    --detach \
    --init \
    --network $(network_name) \
    --network-alias ragger \
    --name $(ragger_service_name) \
    -p 5537:5537 \
    --env NO_PROMETHEUS \
    --read-only \
    --tmpfs /tmp \
    --restart no \
      cyberdojo/ragger:${CYBER_DOJO_RAGGER_TAG})
}

# - - - - - - - - - - - - - - - - - - - - - - -

hiker_service_name()
{
  echo hiker
}

remove_hiker_service()
{
  docker rm --force $(hiker_service_name) > /dev/null || true
}

run_hiker_service()
{
  docker run \
    --user nobody \
    --init \
    --network $(network_name) \
    --name $(hiker_service_name) \
    --env NO_PROMETHEUS \
    --env SRC_DIR=$(src_dir_abs) \
    --read-only \
    --tmpfs /tmp \
    --restart no \
    --volume $(src_dir_abs):$(src_dir_abs):ro \
      cyberdojofoundation/image_hiker:latest
}

# - - - - - - - - - - - - - - - - - - - - - - -

export $(version_tags)
create_docker_network
start_languages_service
start_runner_service
start_ragger_service
sleep 2 # TODO: proper wait...
run_hiker_service

# if something goes wrong we need to look at ragger's log
# docker logs $(ragger_service_name)
