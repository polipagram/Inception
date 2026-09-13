# Inception — User Documentation

## Documentation

* [Project Overview — README](README.md)
* [User Documentation](USER_DOC.md)
* [Developer Documentation](DEV_DOC.md)

---

## 1. Overview

This project provides a WordPress website running through a Docker-based infrastructure.

The stack contains three services:

```text
Browser
   │
 HTTPS :443
   │
   ▼
NGINX
   │
   ▼
WordPress + PHP-FPM
   │
   ▼
MariaDB
```

| Service   | Purpose                                 |
| --------- | --------------------------------------- |
| NGINX     | HTTPS web server and public entry point |
| WordPress | Website and administration interface    |
| PHP-FPM   | Executes WordPress PHP code             |
| MariaDB   | Stores WordPress database data          |

---

## 2. Starting the Project

From the root of the repository:

```bash
make
```

This prepares the persistent data directories and builds and starts the containers.

The equivalent Docker Compose command is:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

---

## 3. Stopping the Project

Stop the services:

```bash
make down
```

This runs:

```bash
docker compose -f srcs/docker-compose.yml down
```

The containers and Docker network are removed, but the persistent data remains.

To completely clean the project, including volumes:

```bash
make fclean
```

> **Warning:** `make fclean` removes the Docker volumes. Persistent WordPress and MariaDB data may be lost.

---

## 4. Accessing the Website

The website is served through NGINX using HTTPS on port `443`.

Open:

```text
https://<DOMAIN_NAME>
```

The domain is configured through the project's environment configuration.

---

## 5. WordPress Administration

The WordPress administration panel is available at:

```text
https://<DOMAIN_NAME>/wp-admin/
```

The administrator username is configured through:

```text
WP_ADMIN_USER
```

The administrator email is configured through:

```text
WP_ADMIN_EMAIL
```

The administrator password is stored in:

```text
secrets/wp_admin_passwd.txt
```

---

## 6. WordPress User

The normal WordPress user's configuration is provided through:

```text
WP_USER
WP_USER_EMAIL
```

The password is stored in:

```text
secrets/wp_user_passwd.txt
```

---

## 7. Database Credentials

MariaDB credentials are managed through Docker secrets.

```text
secrets/
├── root_passwd.txt
└── user_passwd.txt
```

The database name and username are configured through environment variables:

```text
MYSQL_DATABASE
MYSQL_USER
```

The MariaDB host used by WordPress is configured through:

```text
MYSQL_HOST
```

Do not publish the contents of the secret files.

---

## 8. Checking the Services

Check the containers:

```bash
make ps
```

or:

```bash
docker compose -f srcs/docker-compose.yml ps
```

A healthy stack should have:

```text
mariadb
wordpress
nginx
```

running.

---

## 9. Checking Logs

Follow all service logs:

```bash
make logs
```

This is equivalent to:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

You can also inspect an individual container:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

---

## 10. Persistent Data

The project stores persistent data under:

```text
$HOME/data/
├── mariadb/
└── wordpress/
```

These directories are created automatically by:

```bash
make prepare
```

The database and WordPress data therefore survive normal:

```bash
make down
```

operations.

Do not use:

```bash
make fclean
```

if you need to preserve the existing project data.

---

## 11. Quick Commands

| Command        | Purpose                                |
| -------------- | -------------------------------------- |
| `make`         | Prepare, build and start the project   |
| `make prepare` | Create persistent data directories     |
| `make build`   | Build images                           |
| `make up`      | Start containers                       |
| `make down`    | Stop and remove containers             |
| `make logs`    | Follow service logs                    |
| `make ps`      | Show service status                    |
| `make fclean`  | Remove containers, volumes and orphans |
| `make re`      | Full rebuild and restart               |

For technical details, see the [Developer Documentation](DEV_DOC.md).

