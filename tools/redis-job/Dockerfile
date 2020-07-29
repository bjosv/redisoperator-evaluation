FROM golang:1.14.4-stretch as builder
COPY . /build
WORKDIR /build
ENV GO111MODULE=on
RUN CGO_ENABLED=0 GOOS=linux go build -o redis-job

FROM alpine:latest
WORKDIR /root/
RUN apk add --no-cache tzdata
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /build .
CMD ["./redis-job"]
