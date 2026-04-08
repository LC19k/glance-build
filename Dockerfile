# Stage 1 — Build Glance from source
FROM golang:1.24.3-alpine3.21 AS build

# Alpine images do NOT include git — install it
RUN apk add --no-cache git

WORKDIR /src

# Pin to a specific upstream commit for stable builds
ARG GLANCE_REF=main

# Clone Glance from GitHub and check out the desired ref
RUN git clone https://github.com/glanceapp/glance.git . \
    && git checkout "${GLANCE_REF}"

# Build the Glance binary from repo root
RUN CGO_ENABLED=0 go build -o glance .

# Stage 2 — Runtime image
FROM alpine:3.21

WORKDIR /app

# Copy the built binary
COPY --from=build /src/glance /app/glance

# Create config + icons directories
RUN mkdir -p /app/config /app/icons

EXPOSE 8080/tcp

ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
