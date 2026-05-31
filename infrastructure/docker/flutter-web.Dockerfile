# Builder stage: contains Flutter and compiles the web app into static files.
FROM --platform=$BUILDPLATFORM ghcr.io/cirruslabs/flutter:3.41.2 AS builder

# Build-time values are compiled into the Flutter web bundle via --dart-define.
ARG APP_ENV=dev
ARG API_BASE_URL=http://raspberrypi.tail164eef.ts.net:30080

WORKDIR /src/app

# Copy pubspec files first so dependency downloads stay cached when app source changes.
COPY apps/trust-game-app/pubspec.yaml apps/trust-game-app/pubspec.lock ./
RUN flutter pub get

# Copy the full Flutter app after dependencies are restored.
COPY apps/trust-game-app ./

# Flutter web produces static HTML, JavaScript, CSS, and assets.
RUN flutter build web \
    --dart-define=APP_ENV=${APP_ENV} \
    --dart-define=API_BASE_URL=${API_BASE_URL}

# Runtime stage: Nginx serves the static Flutter build; no Flutter process runs here.
FROM nginx:1.29-alpine

# Replace the default Nginx site with the Flutter single-page-app configuration.
COPY infrastructure/docker/nginx/flutter-web.conf /etc/nginx/conf.d/default.conf
# Copy the compiled web assets into the Nginx document root.
COPY --from=builder /src/app/build/web /usr/share/nginx/html
