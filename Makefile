DIR_BACKEND  = ../deckfusion-backend
DIR_LANDING  = ../deckfusion-landing

all: rebuild up

up:
	docker compose up -d

down:
	docker compose down

build: check-env
	$(MAKE) -C ../deckfusion-backend build
	$(MAKE) -C ../deckfusion-landing build
	docker compose build

rebuild: check-env
	$(MAKE) -C ../deckfusion-backend rebuild
	$(MAKE) -C ../deckfusion-landing rebuild
	docker compose build --no-cache

heroku-login:
	$(eval HEROKU_USER := $(shell heroku whoami 2>/dev/null))
	@if [ -z "$(HEROKU_USER)" ]; then \
		echo "Not logged in to Heroku. Logging in..."; \
		heroku login; \
	else \
		echo "Already logged in as $(HEROKU_USER)"; \
	fi

heroku-push-backend: build heroku-login
	heroku container:login
	(cd $(DIR_BACKEND) && heroku container:push web worker beat --recursive --app cloned-deckfusion-backend)

heroku-release-backend: heroku-login
	heroku container:login
	(cd $(DIR_BACKEND) && heroku container:release web worker beat --app cloned-deckfusion-backend)

heroku-push-release-backend: heroku-push-backend heroku-release-backend

hpr-backend: heroku-push-release-backend

heroku-push-landing: build heroku-login
	heroku container:login
	(cd $(DIR_LANDING) && heroku container:push web --app cloned-deckfusion-landing)

heroku-release-landing: heroku-login
	heroku container:login
	(cd $(DIR_LANDING) && heroku container:release web --app cloned-deckfusion-landing)

heroku-push-release-landing: heroku-push-landing heroku-release-landing

hpr-landing: heroku-push-release-landing

clean:
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker stop
	- docker ps -a --filter "name=deckfusion" -q | xargs -r docker rm -f
	- docker images --filter "reference=backend_base*" -q | xargs -r docker rmi -f
	- docker images --filter "reference=deckfusion*" -q | xargs -r docker rmi -f
	$(MAKE) -C ../deckfusion-landing clean
	$(MAKE) -C ../deckfusion-backend clean

fclean: clean
	- docker volume ls --filter "name=deckfusion" -q | xargs -r docker volume rm
	- docker network ls --filter "name=deckfusion" -q | xargs -r docker network rm
	$(MAKE) -C ../deckfusion-landing fclean
	$(MAKE) -C ../deckfusion-backend fclean

re: fclean rebuild up

check-env:
	@test -f .env || (echo ".env not found. Copying .env.example to .env."; cp .env.example .env)

.PHONY: \
	all build rebuild up down \
	heroku-login \
	heroku-push-landing heroku-release-landing heroku-push-release-landing hpr-landing \
	clean fclean re check-env
