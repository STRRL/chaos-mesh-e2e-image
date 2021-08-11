#!/usr/bin/env bash

# Copyright 2020 Chaos Mesh Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This script runs before all e2e jobs to prepare shared files.
# This is optional. We only use it in CI to speed up our e2e process.
#

set -e

if [ "$IN_DOCKER" == "1" ]; then
    export IN_DOCKER=0

    cd /
    git clone https://github.com/chaos-mesh/chaos-mesh.git --depth=1 --single-branch
    cd chaos-mesh

    DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create --use --name chaos-mesh-builder --config ./ci/builder.toml

    make DOCKER_CACHE=1 DOCKER_CACHE_DIR=/mnt GO_BUILD_CACHE=/mnt DISABLE_CACHE_FROM=1 image
    make DOCKER_CACHE=1 DOCKER_CACHE_DIR=/mnt GO_BUILD_CACHE=/mnt DISABLE_CACHE_FROM=1 image-e2e-helper
    make DOCKER_CACHE=1 DOCKER_CACHE_DIR=/mnt GO_BUILD_CACHE=/mnt DISABLE_CACHE_FROM=1 image-chaos-mesh-e2e

    rm -rf /chaos-mesh
else
    docker run --volume $(pwd)/cache:/mnt --privileged --env IN_DOCKER=1 --env DOCKER_IN_DOCKER_ENABLED="true" --rm -it --entrypoint runner.sh hub.pingcap.net/chaos-mesh/chaos-mesh-e2e-base /update-cache.sh
    sudo tar -czvf cache.tar.gz cache
fi
