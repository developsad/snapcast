ARG BUILD_FROM
FROM $BUILD_FROM

# Install S6 Overlay
WORKDIR /
COPY rootfs /

# Update package index and add repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update --no-cache

# Install all required packages
RUN apk add --no-cache \
    alsa-lib \
    avahi \
    avahi-compat-libdns_sd \
    dbus \
    pulseaudio-alsa \
    snapcast \
    librespot

# Set permissions
RUN chmod a+x /etc/services.d/*/run && \
    chmod a+x /etc/cont-init.d/*

LABEL \
    io.hass.name="Snapcast Server" \
    io.hass.description="Snapcast server with Spotify connect support" \
    io.hass.type="addon" \
    io.hass.version="0.2.1"

# Set working directory
WORKDIR /

# Use s6-overlay as entrypoint
ENTRYPOINT ["/init"]
CMD []