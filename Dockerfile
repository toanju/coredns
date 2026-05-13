FROM golang:1.26.3@sha256:313faae491b410a35402c05d35e7518ae99103d957308e940e1ae2cfa0aac29b AS build

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

FROM gcr.io/distroless/static-debian12:nonroot@sha256:a9329520abc449e3b14d5bc3a6ffae065bdde0f02667fa10880c49b35c109fd1
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /coredns /coredns
USER nonroot:nonroot
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
