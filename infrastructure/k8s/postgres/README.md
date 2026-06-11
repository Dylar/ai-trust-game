# PostgreSQL Kubernetes Values

This directory owns Kubernetes values for the PostgreSQL database used by backend persistence.

```text
values.yaml        shared PostgreSQL defaults across environments
values-dev.yaml    PostgreSQL in atg-dev
values-test.yaml   PostgreSQL in atg-test
values-prod.yaml   PostgreSQL in atg-prod
```

The chart renders a Secret for database credentials and a PersistentVolumeClaim for PostgreSQL data.

Current Secret keys:

```text
POSTGRES_USER      database username
POSTGRES_PASSWORD  database password
POSTGRES_DB        database name
```

Current persistence values:

```text
persistence.enabled           enables the PostgreSQL data PVC
persistence.size              requested PVC size
persistence.storageClassName  optional storage class name
```
