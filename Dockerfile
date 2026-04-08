# Stage 1 — Build Glance from source
FROM golang:1.24.3-alpine3.21 AS build

RUN apk add --no-cache git

WORKDIR /src

# Clone Glance from GitHub
RUN git clone https://github.com/glanceapp/glance.git .

# Build the Glance binary (root build, not cmd/)
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
