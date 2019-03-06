FROM 872941275684.dkr.ecr.us-east-1.amazonaws.com/alpine-go AS builder

WORKDIR /go/src/github.com/canary-health/eli-pgdb-test/
COPY . .

FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /tmp/canarypasswd /etc/passwd
WORKDIR /go/bin
COPY --from=builder /go/src/github.com/canary-health/eli-pgdb-test/bin/eli-pgdb-test /go/bin/
USER canary
ENTRYPOINT ["./eli-pgdb-test"]
