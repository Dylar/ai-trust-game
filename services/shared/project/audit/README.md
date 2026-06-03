# Shared Audit Contracts

This package contains project-specific audit event contracts and producer helpers shared by services.

It is intentionally limited to the event and sink boundary needed by event producers, including the HTTP sink for
delivery to `audit-service`.
Audit analysis, repositories, read models, and summarization belong to `services/audit-service/`.
