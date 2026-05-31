# Builder stage: contains the Go toolchain and compiles the selected service.
FROM golang:1.24-alpine AS builder

# SERVICE selects which service under ./services/<name>/cmd is built.
# TARGETOS and TARGETARCH are provided by Docker buildx for cross-platform builds.
ARG SERVICE
ARG TARGETOS
ARG TARGETARCH

WORKDIR /src

# Copy module files first so dependency downloads stay cached when only source files change.
COPY go.mod go.sum ./
RUN go mod download

# Copy only the Go source trees required to build service binaries.
COPY pkg ./pkg
COPY services ./services

# Fail early when the caller forgot to pass --build-arg SERVICE=<name>.
RUN test -n "${SERVICE}"
# Build one selected Go service into a standalone binary for the runtime image.
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64} go build -o /out/service ./services/${SERVICE}/cmd

# Runtime stage: small image with only certificates and the compiled binary.
FROM alpine:3.22

# Run the service as an unprivileged user and include CA certificates for outbound HTTPS calls.
RUN addgroup -S app && adduser -S -G app app \
    && apk add --no-cache ca-certificates

WORKDIR /app

# Copy the compiled binary from the builder stage; the Go toolchain does not end up in this image.
COPY --from=builder /out/service /app/service

# The service listens on this container port; host mapping is handled by Docker Compose or Kubernetes.
ENV PORT=8080
EXPOSE 8080

# Drop privileges before starting the service.
USER app

# Start the compiled service binary.
ENTRYPOINT ["/app/service"]
