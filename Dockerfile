# syntax=docker/dockerfile:1.2

# STAGE 1

FROM scratch AS builder

ADD alpine-minirootfs-3.23.3-x86_64.tar.gz /

WORKDIR /app

RUN apk add --no-cache git openssh-client

RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh git clone git@github.com:Jakub-JD/pawcho6.git .

ARG VERSION="1.0"

RUN echo '#!/bin/sh' > create_app.sh && \
    echo 'echo "<!DOCTYPE html><html lang=\"pl\"><head><meta charset=\"UTF-8\"><title>PAwChO Lab 6 JF</title></head><body>" > /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "<h1>Aplikacja PAwChO - Lab 6</h1>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "<p>Wersja aplikacji: '${VERSION}'</p>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "<p>Nazwa serwera (Hostname): $(hostname)</p>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "<p>Adres IP serwera: $(hostname -i)</p>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "<p>Autor: Jakub Fus</p>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    echo 'echo "</body></html>" >> /usr/share/nginx/html/index.html' >> create_app.sh && \
    chmod +x create_app.sh

# STAGE 2

FROM nginx:alpine

LABEL org.opencontainers.image.authors="Jakub Fus"
LABEL org.opencontainers.image.source="https://github.com/Jakub-JD/pawcho6"

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

COPY --from=builder /app/create_app.sh /docker-entrypoint.d/40-create_app.sh

HEALTHCHECK --interval=30s --timeout=30s --start-period=0s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80
