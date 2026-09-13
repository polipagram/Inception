# Inception — Developer Documentation

## Documentation

* [Project Overview — README](README.md)
* [User Documentation](USER_DOC.md)
* [Developer Documentation](DEV_DOC.md)

---

## 1. Project Architecture

The project is composed of three services:

```text
                         HTTPS :443
                             │
                             ▼
                       ┌───────────┐
                       │   NGINX   │
                       └─────┬─────┘
                             │
                         FastCGI
                             │
                             ▼
                     ┌──────────────┐
                     │  WordPress   │
                     │   PHP-FPM    │
                     └──────┬───────┘
                            │
                            │ MySQL
                            ▼
                     ┌──────────────┐
                     │   MariaDB    │
                     └──────────────┘
```

All services are connected to the Docker network:

```text
inception
```

NGINX is the only service exposing a host port:

```text
443:443
```

MariaDB and WordPress communicate internally through the Docker network.

---

# 2. Project Structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
│
├── secrets/
│   ├── root_passwd.txt
│   ├── user_passwd.txt
│   ├── wp_admin_passwd.txt
│   └── wp_user_passwd.txt
│
└── srcs/
    ├── docker-compose.yml
    │
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── 50-server.cnf
        │   └── tools/
        │       └── init.sh
        │
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.cnf
        │   └── tools/
        │       └── init.sh
        │
        └── wordpress/
            ├── Dockerfile
            ├── conf/
            │   └── www.cnf
            └── tools/
                └── init.sh
```

---

# 3. Prerequisites

The project is intended to run inside the required Linux virtual machine.

Required software:

* Docker
* Docker Compose
* Make
* Git

Check the installation:

```bash
docker --version
docker compose version
make --version
git --version
```

Check that the Docker daemon is running:

```bash
docker ps
```

---

# 4. Environment Configuration

The Compose file uses environment variables such as:

```text
MYSQL_DATABASE
MYSQL_USER
MYSQL_HOST
DOMAIN_NAME
WP_ADMIN_USER
WP_ADMIN_EMAIL
WP_USER
WP_USER_EMAIL
```

These values are consumed by Docker Compose and passed to the appropriate services.

Sensitive passwords are not passed directly through the Compose configuration. They are provided using Docker secrets.

---

# 5. Docker Secrets

The project uses four secrets:

```text
secrets/
├── root_passwd.txt
├── user_passwd.txt
├── wp_admin_passwd.txt
└── wp_user_passwd.txt
```

They are declared in:

```text
srcs/docker-compose.yml
```

For example:

```yaml
secrets:
  root_passwd:
    file: ../secrets/root_passwd.txt
```

The secrets are then attached only to the services that require them.

This keeps sensitive credentials separate from normal configuration.

---

# 6. Makefile

The Makefile provides the main developer interface.

```makefile
NAME = inception

COMPOSE = docker compose
YML = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data
```

### `make`

```bash
make
```

Runs:

```text
prepare
   ↓
docker compose up -d --build
```

It creates the persistent data directories and then builds and starts the services.

---

### `make prepare`

```bash
make prepare
```

Creates:

```text
$HOME/data/mariadb
$HOME/data/wordpress
```

These directories are used as persistent storage.

---

### `make build`

```bash
make build
```

Builds all service images without starting the containers.

Equivalent to:

```bash
docker compose -f srcs/docker-compose.yml build
```

---

### `make up`

```bash
make up
```

Starts the existing Compose services in detached mode.

---

### `make down`

```bash
make down
```

Stops and removes the containers and Docker network.

The persistent data remains because the volumes are not removed.

---

### `make logs`

```bash
make logs
```

Follows the logs of all services:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

---

### `make ps`

```bash
make ps
```

Displays the status of the Compose services.

---

### `make fclean`

```bash
make fclean
```

Runs:

```bash
docker compose -f srcs/docker-compose.yml down -v --remove-orphans
```

This removes:

* containers
* networks
* volumes
* orphan containers

Because the volumes are removed, persistent application data can also be deleted.

---

### `make re`

```bash
make re
```

Performs:

```text
fclean
  ↓
all
  ↓
prepare
  ↓
build + start
```

This provides a complete clean rebuild.

---

# 7. Docker Compose Services

The Compose file defines three services.

## MariaDB

```yaml
mariadb:
  build:
    context: ./requirements/mariadb
```

MariaDB is built from the project's own Dockerfile.

It receives:

* database configuration through environment variables
* database passwords through Docker secrets
* persistent database storage through `mariadb_data`

---

## WordPress

```yaml
wordpress:
  build:
    context: ./requirements/wordpress
```

WordPress receives:

* MariaDB connection information
* WordPress configuration
* administrator configuration
* user configuration
* required passwords through Docker secrets

WordPress data is persisted using `wordpress_data`.

---

## NGINX

```yaml
nginx:
  build:
    context: ./requirements/nginx
```

NGINX is the public entry point.

It exposes:

```text
443:443
```

It depends on WordPress.

---

# 8. Docker Network

The project defines:

```yaml
networks:
  inception:
    driver: bridge
```

All three services join this network.

```text
                inception network
        ┌───────────────────────────┐
        │                           │
        │   NGINX ←→ WordPress      │
        │              ↕            │
        │           MariaDB         │
        │                           │
        └───────────────────────────┘
```

Docker's internal DNS allows services to reach each other using their service names.

---

# 9. Volumes and Persistence

The project defines two Docker volumes:

```text
mariadb_data
wordpress_data
```

However, these are not anonymous Docker-managed storage locations.

They use Docker's `local` volume driver with bind options:

```yaml
driver: local

driver_opts:
  type: none
  device: ${HOME}/data/mariadb
  o: bind
```

Therefore the actual persistent data is stored on the host at:

```text
$HOME/data/mariadb
$HOME/data/wordpress
```

The relationship is:

```text
Host
 │
 ├── $HOME/data/mariadb
 │        │
 │        ▼
 │   mariadb_data
 │        │
 │        ▼
 │   /var/lib/mysql
 │
 └── $HOME/data/wordpress
          │
          ▼
     wordpress_data
          │
          ▼
     /var/www/html
```

This means the data survives normal container removal.

---

# 10. Bind Mount vs Docker Volume in This Project

Conceptually, a bind mount directly maps:

```text
Host path → Container path
```

A Docker volume is managed by Docker.

This project uses a hybrid approach:

```text
Docker Volume
      │
      │ local driver + bind
      ▼
Host directory
```

This gives the project a Docker volume abstraction while keeping the persistent data in explicit directories under:

```text
$HOME/data/
```

This is important when inspecting where the project's persistent data actually lives.

---

# 11. MariaDB Files

```text
srcs/requirements/mariadb/
├── Dockerfile
├── conf/
│   └── 50-server.cnf
└── tools/
    └── init.sh
```

### `Dockerfile`

Defines the MariaDB image.

### `50-server.cnf`

Contains MariaDB server configuration.

### `init.sh`

Initializes the database and users before the database server starts normally.

---

# 12. WordPress Files

```text
srcs/requirements/wordpress/
├── Dockerfile
├── conf/
│   └── www.cnf
└── tools/
    └── init.sh
```

### `Dockerfile`

Builds the WordPress/PHP-FPM environment.

### `www.cnf`

Contains PHP-FPM pool configuration.

### `init.sh`

Performs WordPress initialization and configuration.

---

# 13. NGINX Files

```text
srcs/requirements/nginx/
├── Dockerfile
├── conf/
│   └── nginx.cnf
└── tools/
    └── init.sh
```

### `Dockerfile`

Builds the NGINX image.

### `nginx.cnf`

Contains the NGINX web server and TLS configuration.

### `init.sh`

Performs required initialization before NGINX starts.

---

# 14. Development Workflow

A normal development cycle is:

```text
Modify files
    │
    ▼
make
    │
    ▼
Build images
    │
    ▼
Start containers
    │
    ▼
make ps
    │
    ▼
make logs
    │
    ▼
Test website
```

After modifying a Dockerfile or another file used during image construction:

```bash
make
```

or:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

---

# 15. Debugging

Check the containers:

```bash
make ps
```

Check logs:

```bash
make logs
```

Inspect a specific container:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Enter a running container:

```bash
docker exec -it nginx bash
```

or:

```bash
docker exec -it wordpress bash
```

or:

```bash
docker exec -it mariadb bash
```

Useful checks inside a container include:

```bash
ps
```

```bash
ls
```

```bash
cat <configuration-file>
```

---

# 16. Resetting the Infrastructure

For a normal restart:

```bash
make down
make up
```

For a rebuild:

```bash
make
```

For a complete reset:

```bash
make fclean
make
```

The last option removes the existing Docker volumes before recreating the infrastructure, so it should only be used when resetting the persistent data is intended.

---

# 17. Data Lifecycle

Normal cleanup:

```text
make down
     │
     ├── containers removed
     ├── network removed
     └── persistent data remains
```

Full cleanup:

```text
make fclean
     │
     ├── containers removed
     ├── network removed
     ├── volumes removed
     └── persistent data removed
```

This distinction is important during development and testing.

---

# 18. Developer Checklist

Before considering the project ready:

```text
[ ] Docker installed
[ ] Docker Compose available
[ ] Docker daemon running
[ ] Environment configuration available
[ ] Secrets available
[ ] Data directories created
[ ] MariaDB image builds
[ ] WordPress image builds
[ ] NGINX image builds
[ ] All containers start
[ ] Docker network works
[ ] MariaDB data persists
[ ] WordPress data persists
[ ] HTTPS works
[ ] WordPress website works
[ ] WordPress administration works
[ ] Logs contain no unexpected errors
```

For a simpler explanation of using the finished project, see the [User Documentation](USER_DOC.md).
