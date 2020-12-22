FROM golang:1.15.6-buster as go_build

WORKDIR /
RUN git clone https://github.com/YangKeao/chaos-mesh.git --depth=1 -b update-e2e-base-image
WORKDIR /chaos-mesh

ARG http_proxy
ARG https_proxy

RUN make ensure-all
RUN make e2e-build

FROM gcr.io/k8s-testimages/kubekins-e2e:v20200311-1e25827-master

RUN echo "DOCKER_OPTS=\"\${DOCKER_OPTS} --registry-mirror=\"https://registry-mirror.pingcap.net\"\"" | \
    tee --append /etc/default/docker

RUN mkdir -p /usr/local/bin/chaos-mesh-e2e
COPY --from=go_build /chaos-mesh/output/bin/ /usr/local/bin/chaos-mesh-e2e
COPY --from=go_build /root/.cache/go-build /root/.cache/go-build
RUN rm -rf /go
COPY --from=go_build /go /go_build
COPY cache.tar.gz /cache.tar.gz
COPY update-cache.sh /update-cache.sh
