# 🛡️ Database Backup & Restore Guide (Using `pg_dump`)

This guide explains how to perform full logical backups and restore our `E-commerce Management` PostgreSQL database using `pg_dump` and `pg_restore`.

---

## 📦 Full Backup (Logical Dump)

Perform a full compressed backup of the `ecommercewebsite` database. This is typically done **once per week** or according to the backup policy.

### 🔧 Backup Command

```bash
pg_dump -U postgres -F c \
  -f /PATH/TO/BACKUP_DIRECTORY/ecommercewebsite-$(date +%F).backup \
  ecommercewebsite
```

### 📌 Notes

* Replace `/PATH/TO/BACKUP_DIRECTORY/` with the actual folder path where backups will be stored.
* The output is a single `.backup` file.
* The `-F c` flag creates a compressed custom-format backup, suitable for `pg_restore`.
* You may be prompted for the PostgreSQL user password unless using environment variables or `.pgpass`.

### ✅ Example

```bash
pg_dump -U postgres -F c \
  -f /Users/macbook/Desktop/E-commerce_Database/backups/base/ecommercewebsite-$(date +%F).backup \
  ecommercewebsite
```

---

## 🧹 Automatically Delete Backups Older Than 4 Weeks

To avoid running out of disk space, remove backup files older than 28 days:

```bash
find /PATH/TO/BACKUP_DIRECTORY/ -type f -name "*.backup" -mtime +28 -exec rm -f {} \;
```

### ✅ Example

```bash
find /Users/macbook/Desktop/E-commerce_Database/backups/base/ -type f -name "*.backup" -mtime +28 -exec rm -f {} \;
```

---

## 🔄 Restore Backup Guide

### ⚙️ 1. Restore to a New Database

#### Step 1: Create a new empty database

```bash
createdb -U postgres new_database_name
```

Replace `new_database_name` with the name you want.

---

#### Step 2: Restore the backup into the new database

```bash
pg_restore -U postgres -d new_database_name /path/to/your/backup-file.backup
```

---

### ⚙️ 2. Restore by Overwriting an Existing Database

> ⚠️ **Warning:** This will delete all current data in the existing database!

#### Step 1: Drop the existing database

```bash
dropdb -U postgres existing_database_name
```

#### Step 2: Recreate the database

```bash
createdb -U postgres existing_database_name
```

#### Step 3: Restore the backup

```bash
pg_restore -U postgres -d existing_database_name /path/to/your/backup-file.backup
```

---

### ✅ Restore Example

Restore to a new database example:

```bash
createdb -U postgres ecommercewebsite_restore
pg_restore -U postgres -d ecommercewebsite_restore /Users/macbook/Desktop/E-commerce_Database/backups/base/ecommercewebsite-2025-07-18.backup
```