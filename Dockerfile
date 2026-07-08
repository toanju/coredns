FROM golang:1.26.5@sha256:63f132d58c1f589f0dcda584933a9bb44bfda1150f1506377f5a902f34d86033 AS build

RUN export DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive \
  DEBIAN_PRIORITY=critical \
  TERM=linux ; \
  apt-get -qq update ; \
  apt-get -yq upgrade ; \
  apt-get -yq install ca-certificates libcap2-bin; \
  apt-get clean

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY main.go .
RUN CGO_ENABLED=0 go build -v -o /coredns
RUN setcap cap_net_bind_service=+ep /coredns

FROM gcr.io/distroless/static-debian12:nonroot@sha256:b7bb25d9f7c31d2bdd1982feb4dafcaf137703c7075dbe2febb41c24212b946f
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /coredns /coredns
USER nonroot:nonroot
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
