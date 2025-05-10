ARG BUILD_FROM
FROM $BUILD_FROM

# Update package index and add repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.16/community" >> /etc/apk/repositories && \
    apk update --no-cache

# Install runtime dependencies
RUN apk add --no-cache \
    alsa-lib \
    avahi \
    avahi-compat-libdns_sd \
    dbus \
    pulseaudio-alsa \
    snapcast

# Install build dependencies
RUN apk add --no-cache \
    rust=1.60.0-r2 \
    cargo=1.60.0-r2 \
    build-base \
    protobuf-dev \
    alsa-lib-dev \
    python3 \
    git

# Clone and build librespot from source
RUN git clone https://github.com/librespot-org/librespot.git && \
    cd librespot && \
    git checkout v0.4.2 && \
    cargo build --release --no-default-features --features pulseaudio-backend,alsa-backend && \
    cp target/release/librespot /usr/local/bin/ && \
    cd .. && \
    rm -rf librespot

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