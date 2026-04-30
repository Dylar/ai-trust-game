FROM ghcr.io/cirruslabs/flutter:3.41.2 AS builder

ARG APP_FLAVOR=dev
ARG API_BASE_URL=http://localhost:8080

WORKDIR /src/app

COPY app/pubspec.yaml app/pubspec.lock ./
RUN flutter pub get

COPY app ./

RUN flutter build web \
    --dart-define=APP_FLAVOR=${APP_FLAVOR} \
    --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:1.29-alpine

COPY infrastructure/docker/nginx/flutter-web.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /src/app/build/web /usr/share/nginx/html
