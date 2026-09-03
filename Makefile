NAME = inception

COMPOSE = docker compose
YML = srcs/docker-compose.yml

all:
	$(COMPOSE) -f $(YML) up -d --build

build:
	$(COMPOSE) -f $(YML) build

up:
	$(COMPOSE) -f $(YML) up -d

down:
	$(COMPOSE) -f $(YML) down

logs:
	$(COMPOSE) -f $(YML) logs -f

ps:
	$(COMPOSE) -f $(YML) ps

fclean:
	$(COMPOSE) -f $(YML) down -v --remove-orphans

re: fclean all