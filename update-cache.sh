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

if [ "$IN_DOCKER" == "1" ]; then
    DOCKER_CLI_EXPERIMENTAL=enabled docker buildx create --use --name chaos-mesh-builder

    cd /
    git clone https://github.com/YangKeao/chaos-mesh.git --depth=1 --single-branch -b update-e2e-base-image
    cd chaos-mesh
    make DOCKER_CACHE=1 CACHE_DIR=/mnt image
    rm -rf /chaos-mesh
else
    docker run --mount type=bind,source=$(pwd)/docker-cache,target=/mnt --privileged --env IN_DOCKER=1 --env DOCKER_IN_DOCKER_ENABLED="true" --env HTTP_PROXY=$HTTP_PROXY --env HTTPS_PROXY=$HTTPS_PROXY --rm -it --entrypoint runner.sh hub.pingcap.net/yangkeao/chaos-mesh-e2e-base /update-cache.sh
    tar -czvf docker-cache.tar.gz docker-cache
fi