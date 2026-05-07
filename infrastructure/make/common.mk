TARGET_ENV ?= dev
TAILSCALE_HOST ?= raspberrypi.tail164eef.ts.net

ifeq ($(TARGET_ENV),dev)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30080
else ifeq ($(TARGET_ENV),test)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30081
else ifeq ($(TARGET_ENV),prod)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30082
else
API_BASE_URL ?= http://$(TAILSCALE_HOST)
endif
