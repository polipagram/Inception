*This project has been created as part of the 42 curriculum by kbouarfa.*

# Inception

## Description

**Inception** is a 42 system administration project focused on building a small web infrastructure using **Docker** and **Docker Compose**.

The goal is to create a complete WordPress website composed of several independent services running in isolated containers:

```text
                         Browser
                            │
                         HTTPS
                            │
                            ▼
                     ┌─────────────┐
                     │    NGINX    │
                     │  TLS 1.2/1.3│
                     └──────┬──────┘
                            │
                         FastCGI
                            │
                            ▼
                     ┌─────────────┐
                     │  WordPress  │
                     │   PHP-FPM   │
                     └──────┬──────┘
                            │
                          MySQL
                            │
                            ▼
                     ┌─────────────┐
                     │   MariaDB   │
                     └─────────────┘
```

The three main services are:

| Service       | Role                                              |
| ------------- | ------------------------------------------------- |
| **NGINX**     | Web server, HTTPS/TLS termination and entry point |
| **WordPress** | Web application                                   |
| **MariaDB**   | Database server                                   |

Docker Compose connects these services through a dedicated Docker network.

The project also uses:

* Docker images built from custom Dockerfiles
* Docker Compose
* HTTPS/TLS
* Docker volumes for persistent data
* Docker secrets for sensitive credentials
* Environment variables for non-sensitive configuration
* PHP-FPM for executing WordPress PHP code

---

## Project Structure

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
        │
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

Each service contains its own Dockerfile, configuration and initialization script.

---

# Docker Architecture

Docker provides isolated environments called **containers**.

Instead of installing NGINX, PHP, WordPress and MariaDB directly on the host, the project separates them:

```text
Host
 │
 └── Docker
      ├── NGINX container
      ├── WordPress container
      └── MariaDB container
```

An **image** is the blueprint used to create a container.

```text
Dockerfile
    │
    │ docker build
    ▼
Docker Image
    │
    │ docker run / Docker Compose
    ▼
Container
```

Docker images are built in layers. Unchanged layers can be reused from the build cache, which makes subsequent builds faster.

---

# Docker Compose

Docker Compose defines the complete infrastructure in:

```text
srcs/docker-compose.yml
```

It describes:

* services
* image builds
* networks
* volumes
* secrets
* environment variables
* ports
* dependencies

The infrastructure is therefore managed as one application instead of manually starting each container.

---

# Docker Network

The services communicate through a dedicated Docker network:

```text
              Docker network
        ┌─────────────────────────┐
        │                         │
        │   NGINX ←→ WordPress    │
        │              ↕          │
        │           MariaDB       │
        │                         │
        └─────────────────────────┘
```

Docker provides internal DNS, allowing containers to communicate using service names rather than fixed IP addresses.

Only the required public service is exposed to the host. Internal services communicate through the Docker network.

---

# Persistence

Containers are replaceable environments. Important data therefore must not depend on the lifetime of a container.

Docker volumes are used to persist:

* MariaDB database data
* WordPress application data

Conceptually:

```text
Container
    │
    ▼
Docker Volume
    │
    ▼
Persistent data
```

This means that a container can be removed and recreated without automatically losing the data stored in its volumes.

> **Container = replaceable environment. Volume = persistent data.**

---

# Secrets and Environment Variables

Sensitive credentials are stored using Docker secrets.

The project contains:

```text
secrets/
├── root_passwd.txt
├── user_passwd.txt
├── wp_admin_passwd.txt
└── wp_user_passwd.txt
```

Secrets are appropriate for passwords and other sensitive information.

Environment variables are used for normal configuration that does not require the same level of protection.

The basic separation is:

```text
Non-sensitive configuration → Environment variables
Sensitive credentials       → Docker secrets
```

---

# HTTPS / TLS

NGINX is the public entry point of the infrastructure.

HTTPS protects communication between the browser and NGINX.

The project uses TLS 1.2 and TLS 1.3.

```text
Browser
   │
   │ encrypted HTTPS
   ▼
NGINX
   │
   │ internal communication
   ▼
WordPress
```

---

# Virtual Machines vs Docker

| Virtual Machine         | Docker Container       |
| ----------------------- | ---------------------- |
| Virtualizes hardware    | Isolates processes     |
| Has a complete guest OS | Shares the host kernel |
| Heavier                 | Lightweight            |
| More resource intensive | Lower resource usage   |
| Slower startup          | Fast startup           |

A VM behaves like a complete computer running inside another computer.

A Docker container is an isolated process environment that shares the host's kernel.

In Inception, Docker is suitable because each service can be isolated while remaining lightweight and connected through Docker networking.

---

# Docker Secrets vs Environment Variables

| Docker Secrets                     | Environment Variables          |
| ---------------------------------- | ------------------------------ |
| Designed for sensitive data        | Mainly used for configuration  |
| Suitable for passwords             | Convenient for normal settings |
| Mounted inside containers as files | Provided as environment values |

The project uses Docker secrets for passwords and environment variables for non-sensitive configuration.

---

# Docker Network vs Host Network

With a Docker network, containers communicate through an isolated virtual network.

Advantages include:

* service isolation
* internal DNS
* controlled communication
* no need to expose every service publicly

With host networking, a container directly uses the host's network stack. This provides less network isolation and can cause port conflicts.

For Inception, a dedicated Docker network is therefore used.

---

# Docker Volumes vs Bind Mounts

### Docker Volume

A Docker volume is managed by Docker:

```text
Container
    │
    ▼
Docker Volume
    │
    ▼
Persistent data
```

Volumes are appropriate for persistent application and database data.

### Bind Mount

A bind mount maps a specific host path directly into a container:

```text
Host directory
      │
      ▼
Container directory
```

Bind mounts are useful when the host needs direct access to the files, especially during development.

For persistent service data, Docker-managed volumes provide a cleaner abstraction.

---

# Service Responsibilities

### NGINX

* HTTPS entry point
* TLS termination
* Web server
* Forwards PHP requests to PHP-FPM

### WordPress

* Provides the web application
* Runs PHP through PHP-FPM
* Connects to MariaDB

### MariaDB

* Stores WordPress data
* Provides the relational database backend

### Docker Compose

* Builds the service images
* Creates the network
* Creates and manages containers
* Configures volumes, secrets and environment variables

---

# Instructions

## Requirements

The project should be run inside the required Linux virtual machine environment.

Required tools include:

* Docker
* Docker Compose
* Make
* Git

Check Docker:

```bash
docker --version
```

Check Compose:

```bash
docker compose version
```

Check that Docker is running:

```bash
docker ps
```

---

## Build and Start

From the project root:

```bash
make
```

The Makefile builds and starts the infrastructure.

The equivalent Compose command is:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

Where:

* `up` creates and starts services
* `-d` runs them in the background
* `--build` rebuilds images when required

---

## Check the Services

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs
```

Follow logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

---

## Stop the Project

```bash
docker compose -f srcs/docker-compose.yml stop
```

Restart:

```bash
docker compose -f srcs/docker-compose.yml restart
```

Stop and remove containers and network:

```bash
docker compose -f srcs/docker-compose.yml down
```

Remove volumes as well:

```bash
docker compose -f srcs/docker-compose.yml down -v
```

> `down -v` removes persistent Docker volumes. Use it carefully.

---

## Documentation

* [Project Overview — README](README.md)
* [User Documentation](USER_DOC.md)
* [Developer Documentation](DEV_DOC.md)
- [Docker Commands](DOCK_CMDS.md)

# Resources

## Official Documentation

### Docker

* [Docker Documentation](https://docs.docker.com/?utm_source=chatgpt.com) — General Docker concepts, containers and images.
* [Docker Compose Documentation](https://docs.docker.com/compose/?utm_source=chatgpt.com) — Defining and managing multi-container applications.
* [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/?utm_source=chatgpt.com) — Dockerfile instructions and image building.
* [Docker Networking Documentation](https://docs.docker.com/engine/network/?utm_source=chatgpt.com) — Container networking and service communication.
* [Docker Volumes Documentation](https://docs.docker.com/engine/storage/volumes/?utm_source=chatgpt.com) — Persistent Docker storage.
* [Docker Secrets Documentation](https://docs.docker.com/engine/swarm/secrets/?utm_source=chatgpt.com) — Managing sensitive credentials.

### Web Stack

* [NGINX Documentation](https://nginx.org/en/docs/?utm_source=chatgpt.com) — NGINX configuration and web server concepts.
* [WordPress Developer Resources](https://developer.wordpress.org/?utm_source=chatgpt.com) — WordPress development and configuration.
* [MariaDB Documentation](https://mariadb.com/docs/?utm_source=chatgpt.com) — MariaDB server and SQL documentation.
* [PHP-FPM Documentation](https://www.php.net/manual/en/install.fpm.php?utm_source=chatgpt.com) — PHP FastCGI Process Manager.

## Project Documentation

For more detailed information about this implementation:

* [User Documentation](USER_DOC.md) — How to start, stop, access and check the infrastructure.
* [Developer Documentation](DEV_DOC.md) — How to configure, build, debug and maintain the project.
