# Docker Commands

## COMMANDS

```bash
docker --version
```

show if docker is installed and its version

```bash
docker --help
```

shows Docker's available commands and options

---

# CONTAINER CMDS

## `docker ps`

Show me the Docker containers that are currently running.

> ! shows only running containers
> see service/container status

```bash
docker ps
```

## `docker ps -a`

Show all Docker containers including stopped ones.

```bash
docker ps -a
```

## `docker run`

used to create and start a container from a Docker image

**use:**

```bash
docker run IMAGE
```

## `docker stop`

Stops a running container without removing it.

**use:**

```bash
docker stop CONTAINER
```

## `docker start`

Start an existing stopped container.

**use:**

```bash
docker start CONTAINER
```

## `docker restart`

restarts a container

**use:**

```bash
docker restart CONTAINER
```

## `docker rm`

removes a container

running and stopped ones also

**use:**

```bash
# running
docker rm CONTAINER

# stopped
docker rm -f CONTAINER
```

`-f`: Force-remove a container, even if running.

## `docker exec`

It lets you run a command inside an already running container.

> ! only running containers

**use:**

```bash
docker exec CONTAINER COMMAND
```

```bash
docker exec -it CONTAINER bash
```

Open a shell inside a running container.

## `docker logs`

shows the output produced by a container

shows the container's stdout/stderr output

**use:**

```bash
docker logs CONTAINER
```

**follow logs live:**

```bash
docker logs -f CONTAINER
```

---

# IMAGE CMDS

## `docker images`

It lists the Docker images stored on your machine.

Equivalent command:

```bash
docker image ls
```

## `docker pull`

Download an image from a registry.

**use:**

```bash
docker pull IMAGE
```

## `docker rmi`

remove an image

**use:**

```bash
docker rmi IMAGE
```

## `docker image inspect`

show detailed info about an image

**use:**

```bash
docker image inspect IMAGE
```

---

# DOCKER COMPOSE CMDS

## `docker compose`

Used to define and manage multiple Docker services as one application.

Reads the Compose YAML file and manages the services defined inside it.

That YAML file describes things such as services, build contexts, images, networks, volumes, ports, environment variables, and dependencies.

## `docker compose -f`

Specify which Compose YAML file to use.

**use:**

```bash
docker compose -f dir/docker-compose.yml COMMAND
```

`-f`: file

tells Compose which YAML file to use.

You don't have to run Compose from the directory containing the YAML file.

You can specify its location with `-f`.

## `docker compose up`

Create and start the services defined in the Compose file.

**use:**

```bash
docker compose up
```

## `docker compose up -d --build`

Read the Compose YAML file, create and start services and build images when needed.

```bash
docker compose up -d --build
```

`up`: create and start the services

`-d`: detached --> run them in the background (detached)

`--build`: rebuild images before starting.

**why:** Because your Dockerfile or its files may have changed but the existing image still contains the old version.

`--build` makes sure your containers are based on the latest image definition.

> ! Docker cache is still used for unchanged layers:
> `--build` does not necessarily rebuild everything from zero.
> Unchanged layers can still come from cache.

## `docker compose build`

Builds/rebuilds the images defined in the Compose file.

> ! does not start the containers

```bash
docker compose build
```

## `docker compose ps`

Shows the containers and their status for the Compose project.

**use:**

```bash
docker compose ps
```

## `docker compose logs`

Shows the output/logs of the Compose services.

**use:**

```bash
docker compose logs
```

## `docker compose logs -f`

Shows the logs and follows them live.

`-f`: follow

```bash
docker compose logs -f
```

## `docker compose stop`

Stops the Compose services without removing the containers.

**use:**

```bash
docker compose stop
```

## `docker compose start`

Starts existing stopped Compose containers.

**use:**

```bash
docker compose start
```

## `docker compose restart`

Restarts the Compose services.

```bash
docker compose restart
```

## `docker compose down`

Stops and removes the Compose containers and network.

**use:**

```bash
docker compose down
```

## `docker compose down -v`

Stops and removes containers, network, and Compose volumes.

`-v`: remove volumes

> ! volumes may contain persistent data

```bash
docker compose down -v
```

## `docker compose down --remove-orphans`

Removes containers that belong to the Compose project but are no longer defined in the current Compose file.

`--remove-orphans`: remove orphan containers

**Orphan** = old Compose container whose service is no longer in the current Compose file.

They were defined in the YAML and created by the old Compose project but are no longer defined in the current `docker-compose.yml`.

```bash
docker compose down --remove-orphans
```

## `docker compose down -v --remove-orphans`

Full Compose cleanup:

removes containers, network, volumes, and orphan containers.

```bash
docker compose down -v --remove-orphans
```
