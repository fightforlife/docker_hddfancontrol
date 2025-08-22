# --- Stage 1: Build Stage ---
FROM alpine:latest AS builder

# Install build dependencies
RUN apk add --no-cache \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/testing cargo g++ rust git go build-base

# Clone the repository and build the application
WORKDIR /app
RUN git clone https://github.com/desbma/hddfancontrol.git && \
    cd hddfancontrol && \
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) && \
    cargo build --release

RUN git clone https://github.com/adelolmo/hd-idle.git && \
    cd hd-idle && \
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) && \
    make


# --- Stage 2: Final Image ---
FROM alpine:latest

# Install only the runtime dependencies
RUN apk add --no-cache \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/testing smartmontools hdparm sdparm lm-sensors \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/main sed nvme-cli kmod lm-sensors coreutils

# Copy the built binary from the builder stage
COPY --from=builder /app/hddfancontrol/target/release/hddfancontrol /usr/local/bin/hddfancontrol
COPY --from=builder /app/hd-idle/hd-idle /usr/local/bin/hd-idle

# Copy the local script and make it executable
COPY start_services.sh /usr/local/bin/start_services.sh
RUN chmod +x /usr/local/bin/start_services.sh

# Set the command to run the services
CMD ["/usr/local/bin/start_services.sh"]