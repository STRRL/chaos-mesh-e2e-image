FROM golang:1.15.6-buster as go_build

WORKDIR /
RUN git clone https://github.com/chaos-mesh/chaos-mesh.git --depth=1
WORKDIR /chaos-mesh

ARG http_proxy
ARG https_proxy

RUN make ensure-kubebuilder
RUN make ensure-kustomize
RUN make e2e-build
COPY ./prepare-e2e.sh ./hack/prepare-e2e.sh
RUN ./hack/prepare-e2e.sh

FROM gcr.io/k8s-testimages/kubekins-e2e:v20200311-1e25827-master

RUN echo "DOCKER_OPTS=\"\${DOCKER_OPTS} --registry-mirror=\"https://registry-mirror.pingcap.net\"\"" | \
    tee --append /etc/default/docker

RUN mkdir -p /usr/local/bin/chaos-mesh-e2e
COPY --from=go_build /chaos-mesh/output/bin/ /usr/local/bin/chaos-mesh-e2e
COPY --from=go_build /root/.cache/go-build /root/.cache/go-build
RUN rm -rf /go
COPY --from=go_build /go /go
COPY ./update-cache.sh /update-cache.sh