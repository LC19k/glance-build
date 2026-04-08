# Stage 1 — Build Glance from source
FROM golang:1.24.3-alpine3.21 AS build

# Install build dependencies
RUN apk add --no-cache git make nodejs npm

WORKDIR /src

# Pin to a specific upstream commit for stable builds
ARG GLANCE_REF=main

# Clone Glance and check out the desired ref
RUN git clone https://github.com/glanceapp/glance.git . \
    && git checkout "${GLANCE_REF}"

# Build Glance using upstream's official build pipeline
RUN make build

# Stage 2 — Runtime image
FROM alpine:3.21

WORKDIR /app

# Copy the built binary
COPY --from=build /src/glance /app/glance

# Copy static assets (required for UI)
COPY --from=build /src/static /app/static

# Create config + icons directories
RUN mkdir -p /app/config /app/icons

EXPOSE 8080/tcp

ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
