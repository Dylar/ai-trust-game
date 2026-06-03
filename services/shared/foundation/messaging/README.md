# Messaging Foundation

This package defines provider-neutral messaging contracts used by backend services.

Provider implementations, such as RabbitMQ, live in child packages. Project-specific event contracts and routing names
belong in `services/shared/project/` or service-owned packages.
