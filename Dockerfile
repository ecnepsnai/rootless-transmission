FROM alpine:3

LABEL org.opencontainers.image.source="https://github.com/ecnepsnai/rootless-transmission"
LABEL org.opencontainers.image.url="https://github.com/ecnepsnai/rootless-transmission"
LABEL org.opencontainers.image.authors="Ian Spence <ian@ecn.io>"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.title="rootless transmission"
LABEL org.opencontainers.image.description="OCI image for running the Transmission BitTorrent client as a rootless container"

ARG TRANSMISSION_VERSION=3.00

# Download and extract the transmission source
RUN apk add --no-cache curl tar xz && \
    curl -L https://github.com/transmission/transmission-releases/raw/master/transmission-${TRANSMISSION_VERSION}.tar.xz > /source.tar.xz && \
    xz --decompress /source.tar.xz && \
    tar -xf /source.tar && \
    rm /source.tar && \
    apk del --no-cache curl tar xz

# Compile transmission
WORKDIR /transmission-${TRANSMISSION_VERSION}
RUN apk add --no-cache build-base curl-dev libevent-dev intltool && \
    ./configure && make && make install
WORKDIR /
RUN rm -rf /transmission-${TRANSMISSION_VERSION} && apk del --no-cache build-base intltool

# Setup volumes
VOLUME /downloads
VOLUME /config
VOLUME /watch

# Add default settings and entrypoint
ADD settings.json /default_settings.json
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose ports
EXPOSE 51413/tcp
EXPOSE 51413/udp
EXPOSE 9091/tcp

ENTRYPOINT /entrypoint.sh
