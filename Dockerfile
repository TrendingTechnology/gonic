FROM golang:1.15-alpine AS builder
RUN apk add -U --no-cache \
  build-base \
  ca-certificates \
  git \
  sqlite \
  taglib-dev \
  alsa-lib-dev
WORKDIR /src
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN ./_do_build_server

FROM alpine:3.12.3
RUN apk add -U --no-cache \
  ffmpeg \
  ca-certificates \
  tzdata
COPY --from=builder \
  /usr/lib/libgcc_s.so.1 \
  /usr/lib/libstdc++.so.6 \
  /usr/lib/libtag.so.1 \
  /usr/lib/
COPY --from=builder \
  /src/gonic \
  /bin/
VOLUME ["/data", "/music", "/cache"]
EXPOSE 80
ENV TZ ""
ENV GONIC_DB_PATH /data/gonic.db
ENV GONIC_LISTEN_ADDR :80
ENV GONIC_MUSIC_PATH /music
ENV GONIC_PODCAST_PATH /podcasts
ENV GONIC_CACHE_PATH /cache
CMD ["gonic"]
