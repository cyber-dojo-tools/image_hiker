#!/bin/bash

rackup             \
  --env production \
  --host 0.0.0.0   \
  --port 5637      \
  --server thin    \
  --warn           \
    config.ru