FROM golang:1.16.7-buster as go_build

WORKDIR /
RUN git clone https://github.com/chaos-mesh/chaos-mesh.git --depth=1
WORKDIR /chaos-mesh

ARG http_proxy
ARG https_proxy

RUN make ensure-all

FROM gcr.io/k8s-testimages/kubekins-e2e:latest-1.21

RUN echo "DOCKER_OPTS=\"\${DOCKER_OPTS} --registry-mirror=\"https://registry-mirror.pingcap.net\"\"" | \
    tee --append /etc/default/docker

RUN mkdir -p /usr/local/bin/chaos-mesh-e2e
COPY --from=go_build /chaos-mesh/output/bin/ /usr/local/bin/chaos-mesh-e2e
COPY cache.tar.gz /cache.tar.gz
COPY update-cache.sh /update-cache.sh
