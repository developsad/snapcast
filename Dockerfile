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
    git \
    openssl-dev \
    pkgconfig \
    musl-dev \
    cmake \
    linux-headers

# Set environment variables for build
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV OPENSSL_DIR=/usr
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_BUILD_TARGET=x86_64-alpine-linux-musl

# Clone and build librespot from source
RUN git clone --depth 1 --branch v0.4.2 https://github.com/librespot-org/librespot.git && \
    cd librespot && \
    cargo build --target x86_64-alpine-linux-musl --release --no-default-features --features pulseaudio-backend,alsa-backend && \
    install -D -m 755 target/x86_64-alpine-linux-musl/release/librespot /usr/local/bin/ && \
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