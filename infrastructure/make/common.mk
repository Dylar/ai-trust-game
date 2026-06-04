ENV ?= dev
TAILSCALE_HOST ?= raspberrypi.tail164eef.ts.net

ifeq ($(ENV),dev)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30080
else ifeq ($(ENV),test)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30081
else ifeq ($(ENV),prod)
API_BASE_URL ?= http://$(TAILSCALE_HOST):30082
else
API_BASE_URL ?= http://$(TAILSCALE_HOST)
endif
