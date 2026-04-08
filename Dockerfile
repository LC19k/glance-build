# Stage 1 — Build Glance from source.
FROM golang:1.24.3 AS build

WORKDIR /src

# Clone Glance from GitHub
RUN git clone https://github.com/glanceapp/glance.git .

# Build the Glance binary
RUN CGO_ENABLED=0 go build -o glance ./cmd/server

# Stage 2 — Runtime image
FROM alpine:3.19

WORKDIR /app

# Copy the built binary
COPY --from=build /src/glance /app/glance

# Create config + icons directories
RUN mkdir -p /app/config /app/icons

# Expose Glance's default port
EXPOSE 8080

ENTRYPOINT ["/app/glance"]
