# Persistence Foundation

This package area contains provider-neutral persistence support used by backend services.

Provider implementations, such as PostgreSQL, live in child packages. Service-specific repository boundaries, SQL
queries, table ownership, and domain mapping belong in the owning service packages.

Foundation persistence code should stay generic and reusable.
