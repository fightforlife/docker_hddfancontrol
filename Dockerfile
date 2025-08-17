# --- Stage 1: Build Stage ---
FROM alpine:latest AS builder

# Install build dependencies
RUN apk add --no-cache \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/testing cargo g++ rust git

# Clone the repository and build the application
WORKDIR /app
RUN git clone https://github.com/desbma/hddfancontrol.git && \
    cd hddfancontrol && \
    cargo build --release

# --- Stage 2: Final Image ---
FROM alpine:latest

# Install only the runtime dependencies
RUN apk add --no-cache \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/testing smartmontools hdparm sdparm lm_sensors \
    -X http://dl-cdn.alpinelinux.org/alpine/edge/community hd-idle

# Copy the built binary from the builder stage
COPY --from=builder /app/hddfancontrol/target/release/hddfancontrol /usr/local/bin/hddfancontrol

# Copy your local script to the final image
COPY start_services.sh /usr/local/bin/start_services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start_services.sh

# Set the command to run the services
CMD ["/usr/local/bin/start_services.sh"]
