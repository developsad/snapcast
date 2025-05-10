ARG BUILD_FROM
FROM $BUILD_FROM

# Update package index and add repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update --no-cache

# Install required packages
RUN apk add --no-cache \
    alsa-lib \
    avahi \
    avahi-compat-libdns_sd \
    dbus \
    pulseaudio-alsa \
    snapcast

# Install Rust and Cargo first
RUN apk add --no-cache \
    rust \
    cargo

# Install remaining build dependencies
RUN apk add --no-cache \
    build-base \
    protobuf-dev \
    alsa-lib-dev \
    python3

# Build and install librespot
RUN cargo install librespot --version 0.4.2 --no-default-features --features pulseaudio-backend,alsa-backend

# Copy root filesystem
COPY rootfs /

LABEL \
    io.hass.name="Snapcast Server" \
    io.hass.description="Snapcast server with Spotify connect support" \
    io.hass.type="addon" \
    io.hass.version="0.2.1"

# Set working directory
WORKDIR /

# Start script
CMD ["/usr/bin/with-contenv", "bashio"]