# Backup and Restore

## PostgreSQL Backup
Run from the backend server:

```bash
cd /opt/laqta/backend
DATABASE_URL="$DATABASE_URL" BACKUP_DIR=/var/backups/laqta/postgres bash scripts/backup_postgres.sh
```

Cron example:

```cron
15 2 * * * cd /opt/laqta/backend && DATABASE_URL="$DATABASE_URL" BACKUP_DIR=/var/backups/laqta/postgres bash scripts/backup_postgres.sh >> /var/log/laqta-postgres-backup.log 2>&1
```

## PostgreSQL Restore

```bash
gunzip -c /var/backups/laqta/postgres/laqta_postgres_YYYYMMDD_HHMMSS.sql.gz | psql "$DATABASE_URL"
```

Always restore into staging first and validate `/api/v1/ready` before production restore.

## MinIO Backup
Configure MinIO client:

```bash
mc alias set laqta https://minio.example.com "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"
MINIO_ALIAS=laqta MINIO_BUCKET=laqta-media BACKUP_DIR=/var/backups/laqta/minio bash scripts/backup_minio.sh
```

Cron example:

```cron
45 2 * * * cd /opt/laqta/backend && MINIO_ALIAS=laqta MINIO_BUCKET=laqta-media BACKUP_DIR=/var/backups/laqta/minio bash scripts/backup_minio.sh >> /var/log/laqta-minio-backup.log 2>&1
```

## MinIO Restore

```bash
mc mirror --overwrite /var/backups/laqta/minio/laqta_minio_YYYYMMDD_HHMMSS laqta/laqta-media
```

## Restore Test
1. Restore DB into staging.
2. Restore MinIO bucket into staging bucket.
3. Run backend `npm test && npm run build`.
4. Verify health, ready, media download, and authenticated upload.
