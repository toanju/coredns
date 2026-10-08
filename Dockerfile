FROM golang:1.27.2@sha256:5bc7f572bbaa98885a3a1fd9c0aa76b59e3e14e8628bfc316bbfd0c701e4818c AS build

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

FROM gcr.io/distroless/static-debian12:nonroot@sha256:afa5c872c891853ca7fcf1f12c3edb23f7eeef36189728842dd51042ff57f7ab
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /coredns /coredns
USER nonroot:nonroot
EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
