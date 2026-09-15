# sweet-scanner-app Dockerfile — multi-stage, non-root, dumb healthcheck included.
# Build stage compiles the Flutter WEB app; runtime is nginx-unprivileged:
# the whole web server runs as the unprivileged `nginx` user (never root);
# it listens on 8080 INSIDE the container (unprivileged processes cannot
# bind <1024). Host ports (deploy/ports.env: 5088/5089/5090) forward in.
# Flutter image: 3.44.0 is the newest stable the cirruslabs image repo
# publishes — bump in step with .woodpecker/pipeline.yaml when 3.47.x lands.
FROM ghcr.io/cirruslabs/flutter:3.44.0 AS build
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

FROM nginxinc/nginx-unprivileged:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/build/web /usr/share/nginx/html
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
