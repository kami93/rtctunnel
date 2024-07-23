FROM golang:1.22-alpine as builder
RUN apk --no-cache add git gcc musl-dev

ENV GO111MODULE=on
ENV CGO_ENABLED=0

RUN mkdir -p /go/src/github.com/kami93/rtctunnel
WORKDIR /go/src/github.com/kami93/rtctunnel

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -v -ldflags '-extldflags "-static"' \
    -o /usr/local/bin/rtctunnel ./cmd/rtctunnel

FROM alpine:latest
RUN apk add --no-cache --update \
    ca-certificates
WORKDIR /root
COPY --from=0 /usr/local/bin/rtctunnel /usr/local/bin/rtctunnel
CMD ["/usr/local/bin/rtctunnel"]
