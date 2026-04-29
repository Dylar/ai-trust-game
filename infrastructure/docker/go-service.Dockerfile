FROM golang:1.24-alpine AS builder

ARG SERVICE

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY internal ./internal
COPY pkg ./pkg
COPY services ./services

RUN test -n "${SERVICE}"
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/service ./services/${SERVICE}/cmd

FROM alpine:3.22

RUN addgroup -S app && adduser -S -G app app \
    && apk add --no-cache ca-certificates

WORKDIR /app

COPY --from=builder /out/service /app/service

ENV PORT=8080
EXPOSE 8080

USER app

ENTRYPOINT ["/app/service"]
