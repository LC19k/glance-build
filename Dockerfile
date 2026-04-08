# Stage 1 — Build Glance from source
FROM golang:1.24.3-alpine3.21 AS build

RUN apk add --no-cache git

WORKDIR /src

ARG GLANCE_REF=main

# Clone Glance and check out the desired ref
RUN git clone https://github.com/glanceapp/glance.git . \
    && git checkout "${GLANCE_REF}"

# Generate embedded assets
RUN go generate ./...

# Build Glance in release mode (assets embedded)
RUN CGO_ENABLED=0 go build -tags release -o glance .

# Stage 2 — Runtime
FROM alpine:3.21

WORKDIR /app

COPY --from=build /src/glance /app/glance

RUN mkdir -p /app/config /app/icons

EXPOSE 8080

ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
