NAME = inception

COMPOSE = docker compose
YML = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data

all: prepare
	$(COMPOSE) -f $(YML) up -d --build

prepare:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress

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

.PHONY: all prepare build up down logs ps fclean clean re