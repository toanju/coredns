FROM golang:1.22.3-alpine3.19 as build

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY main.go .
RUN go build -v -o /coredns

FROM alpine:3.19
RUN apk --no-cache --no-progress add ca-certificates
COPY --from=build /coredns /coredns
ENTRYPOINT ["/coredns"]
