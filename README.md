# Open Source Deployment Lab

A containerized WordPress deployment lab built with Docker Compose. The
project separates the web server, application runtime, and database into
dedicated services, with persistent storage, network segmentation, and
automated database backup and recovery commands.

## Architecture

``` text
                     Browser
                        |
                  Host port 8080
                        |
                 Nginx container
                 (port 80 / HTTP)
                        |
                  FastCGI :9000
                        |
              WordPress PHP-FPM 8.2
                        |
                 MariaDB :3306
                        |
                 Persistent volume
```

### Services

  ------------------------------------------------------------------------
  Service                 Image                    Responsibility
  ----------------------- ------------------------ -----------------------
  `nginx`                 `nginx:latest`           Serves HTTP requests
                                                   and forwards PHP
                                                   requests to WordPress
                                                   through FastCGI.

  `wordpress`             `wordpress:php8.2-fpm`   Runs the WordPress
                                                   application using
                                                   PHP-FPM.

  `mariadb`               `mariadb:11`             Stores WordPress
                                                   application data.
  ------------------------------------------------------------------------

## Key Features

-   **Multi-container deployment:** Runs Nginx, WordPress PHP-FPM, and
    MariaDB as separate services managed by Docker Compose.
-   **Reverse proxy / FastCGI configuration:** Nginx serves the
    WordPress document root and forwards PHP requests to
    `wordpress:9000`.
-   **Network segmentation:** Nginx is connected to the `public` and
    `private` Compose networks, while WordPress and MariaDB are
    connected to the `private` network.
-   **Persistent storage:** Named Docker volumes preserve WordPress
    files and MariaDB database files across container recreation.
-   **Configuration through environment variables:** Database connection
    settings are supplied through a local `.env` file rather than
    hard-coded in the Compose file.
-   **Database backup and restore:** Makefile targets automate
    `mariadb-dump` and database import operations.
-   **Safety confirmations:** Destructive cleanup and database restore
    targets require explicit confirmation variables.

## Repository Structure

``` text
open_source_deployment_lab/
├── .env.example
├── .gitignore
├── Makefile
├── docker-compose.yml
└── nginx/
    └── default.conf
```

## Prerequisites

-   Docker Engine
-   Docker Compose plugin
-   GNU Make

## Getting Started

### 1. Clone the repository

``` bash
git clone <YOUR_REPOSITORY_URL>
cd open_source_deployment_lab
```

### 2. Configure environment variables

Create your local environment file:

``` bash
cp .env.example .env
```

Edit `.env` and replace the example passwords with strong values.

Example configuration:

``` dotenv
DB_HOST=mariadb:3306
MARIADB_DATABASE=wordpress
DB_USER=wordpress
DB_PASSWORD=change-this-password
MARIADB_ROOT_PASSWORD=change-this-root-password
```

Do not commit `.env` or real credentials to version control. The
repository's `.gitignore` excludes `.env`.

### 3. Start the application

``` bash
make up
```

Or run Docker Compose directly:

``` bash
docker compose up -d
```

### 4. Check running services

``` bash
make ps
```

Or:

``` bash
docker compose ps
```

### 5. Access WordPress

Open the following address in your browser:

``` text
http://localhost:8080
```

Complete the WordPress setup if this is a fresh deployment.

## Useful Commands

  ------------------------------------------------------------------------
  Command                              Description
  ------------------------------------ -----------------------------------
  `make up`                            Starts the services in detached
                                       mode.

  `make ps`                            Displays the Compose service
                                       status.

  `make down`                          Stops and removes containers and
                                       Compose networks without deleting
                                       named volumes.

  `make logs`                          Follows the MariaDB container logs.

  `make backup-db`                     Exports the configured MariaDB
                                       database to `wordpress_backup.sql`.

  `make restore CONFIRM_RESTORE=yes`   Imports `wordpress_backup.sql` into
                                       the configured database after
                                       explicit confirmation.

  `make clean CONFIRM_CLEAN=yes`       Runs `docker compose down -v`,
                                       removing Compose named volumes as
                                       well as containers and networks.
  ------------------------------------------------------------------------

> **Warning:** `make clean CONFIRM_CLEAN=yes` deletes persistent Compose
> volumes, including the database and WordPress files. Use it only when
> you intentionally want to remove the stored data.
>
> **Restore warning:** The restore target imports the SQL dump into the
> configured database. Make a backup first if the current database
> contains data you need to keep.

## Database Backup and Recovery

Create a database backup:

``` bash
make backup-db
```

The dump is written to:

``` text
wordpress_backup.sql
```

Restore the dump:

``` bash
make restore CONFIRM_RESTORE=yes
```

The restore command requires the confirmation variable to reduce
accidental imports.

## Configuration Notes

-   Nginx listens on container port `80`, published on host port `8080`.
-   Nginx forwards PHP requests to the WordPress PHP-FPM service on port
    `9000`.
-   WordPress connects to MariaDB using the Compose service hostname and
    configured environment variables.
-   The WordPress volume is mounted read-only in the Nginx container and
    read-write in the WordPress container.
-   MariaDB data is stored in the `mariadb_data` named volume.
-   `WORDPRESS_CONFIG_EXTRA` disables the built-in file editor in the
    WordPress dashboard.

## Security Considerations

-   Keep `.env` out of Git and use strong, unique database passwords.
-   Do not expose the MariaDB port publicly.
-   Review and pin container image versions before using this lab in a
    production environment; the Nginx image currently uses the mutable
    `latest` tag.
-   Configure HTTPS and production-grade access controls before exposing
    a real deployment to the internet.
-   Treat database backup files as sensitive because they may contain
    application data and user information.

## Scope

This repository demonstrates containerized deployment, service
separation, Nginx/PHP-FPM integration, persistent volumes, Docker
networking, and database backup/recovery automation.

It does not currently include Kubernetes manifests, Terraform
infrastructure provisioning, a CI/CD pipeline, or monitoring
configuration.


